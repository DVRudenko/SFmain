//DOC: объект возвращаемый из ready нельзя нигде сохранять - можно на него
// только подписаться в контексте вызова, т.к. в процессе работы объект
// может быть изменён (после потери связи)
//DOC: объект NauPhone не может быть использован повторно
//DOC: описать последовательность событий при коннекте/дисконнекте
var VERSION = 10;
    function getNauPhone(url) {
		var NauPhone = {};
		NauPhone.emitter = new EventEmitter();
        var request_id = 1,
            requests = {},
            ws,
            INITIAL = 0,
            CONNECTING = 1,
            HANDSHAKE = 2,
            CONNECTED = 3,
            CLOSED = 4,
            state = INITIAL;
        //Transfer error status
        NauPhone.TS_EMPTYADDRESS = 0;
        NauPhone.TS_BADADDRESSFORMAT = 1;
        NauPhone.TS_DIFFERENTTYPECONNECTIONS = 2;
        NauPhone.TS_SOURCECONNECTIONNOTFOUND = 3;
        NauPhone.TS_RESPONSETIMEOUT = 4;
        NauPhone.TS_CONNECTIONTROUBLE = 5;
        NauPhone.TS_RECEIVERETURNERROR = 6;
        NauPhone.TS_BUSY = 7;
        NauPhone.TS_BREAKTRANSFER = 8;
        NauPhone.TS_TRANSFERREDSIDEDISCONNECTED = 9;
        NauPhone.TS_DESTINATIONNOTFOUND = 10;
        function sendRequest(resolve, reject, request) {
            console.log('NAUPHONE JS : send request', request);
            if (state !== HANDSHAKE && state !== CONNECTED) {
                // TODO: new Exception?
                throw 'not connected';
            }
            requests[request_id] = {
                resolve: resolve,
                reject: reject
            };
            request.rid = request_id++;
            NauPhone.emitter.emit('ws_send', request);
            ws.send(JSON.stringify(request));
        }
        function makeRequest(name, params) {
            var key,
                request = {
                    name: name
                };
            params = params || {};
            for (key in params) {
                request[key] = params[key];
            }
            return new Promise(function (resolve, reject) {
                sendRequest(resolve, reject, request);
            });
        }
        function CallPrototype(id) {
            this.id = id;
            this.getState = function () {
                return makeRequest('getState', {id: id}).then(function (callState) {
                    var key;
                    for (key in callState) {
                        if (['answerTime', 'hangupTime', 'creationTime'].indexOf(key) !== -1) {
                            callState[key] = new Date(callState[key] * 1000);
                        }
                    }
                    return callState;
                });
            };
            this.getParams = function () {
                return makeRequest('getParams', {id: id});
            };
        };
        function Call(id) {
            CallPrototype.call(this, id);
            this.answer = function () {
                return makeRequest('answer', {id: id});
            };
            this.close = function () {
                return makeRequest('close', {id: id});
            };
            this.hangup = function () {
                return makeRequest('hangup', {id: id});
            };
            this.hold = function (on) {
                return makeRequest('hold', {id: id, on: on});
            };
            this.transfer = function (transferNumber) {
                return makeRequest('transfer', {id: id, number: transferNumber});
            };
            this.transferWithCallBack = function (transferNumber) {
                return makeRequest('transferWithCallBack', {id: id, number: transferNumber});
            };
            this.conferenceTransfer = function (transferNumber) {
                return makeRequest('conferenceTransfer', {id: id, number: transferNumber});
            };
            this.consultationTransfer = function (transferNumber) {
                return makeRequest('consultationTransfer', {id: id, number: transferNumber});
            };
            this.breakTransfer = function () {
                return makeRequest('breakTransfer', {id: id});
            };
            this.textMessageProcessed = function (messageId) {
                return makeRequest('textMessageProcessed', {id: id, messageId: messageId});
            };
            this.mute = function (on) {
                return makeRequest('mute', {id: id, on: on});
            };
            this.activate = function () {
                return makeRequest('setActive', {id: id});
            };
            this.setCallParam = function (name, value) {
                return makeRequest('setCallParam', {id: id, paramName: name, paramValue: value});
            };
            return this;
        }
        Call.prototype = Object.create(CallPrototype.prototype);
        function Conference (id) {
            CallPrototype.call(this, id);
            this.hangupConference = function () {
                return makeRequest('hangupConference', {id: id});
            };
            this.makeConferenceCall = function (url) {
                return makeRequest('makeConferenceCall', {id: id, url: url});
            };
            this.addCallToConference = function (callId) {
                return makeRequest('addCallToConference', {id: id, callId: callId});
            };
            this.removeCallFromConference = function (callId) {
                return makeRequest('removeCallFromConference', {id: id, callId: callId});
            };
            this.leaveConference = function () {
                return makeRequest('leaveConference', {id: id});
            };
            this.joinConference = function () {
                return makeRequest('joinConference', {id: id});
            }
            return this;
        }
        Conference.prototype = Object.create(CallPrototype.prototype);
        function onMessage(ws_message) {
            //console.error('>>> on message >> ');
            //console.error(ws_message);
            var message = JSON.parse(ws_message.data),
                name = message.name,
                handler = requests[message.rid];
            NauPhone.emitter.emit('ws_receive', message);
            delete message.name;
            if (handler) {
                delete requests[message.rid];
                delete message.rid;
                if (name === 'error') {
                    handler.reject(message);
                } else {
                    handler.resolve(message);
                }
            } else if (name === 'userstate' ||
                       name === 'callAddedToConference' ||
                       name === 'callRemovedFromConference' ||
                       name === 'leftConference' ||
                       name === 'joinedConference' ||
                       name === 'transferSucceed' ||
                       name === 'transferFailed' ||
                       name === 'transferCallReturned' ||
                       name === 'newtextmessage' ||
                       name === 'pageurls') {
                NauPhone.emitter.emit(name, message);
            } else if (['callstatus', 'currentcall', 'newcall', 'onclose', 'callparams', 'callparamsupdated'].indexOf(name) !== -1) {
                NauPhone.emitter.emit(name, new Call(message.id));
            } else {
                NauPhone.emitter.emit('error', 'Unknown message \'' + name + '\': ' + JSON.stringify(message));
            }
        }
        NauPhone.ready = function () {
            if (state === CONNECTED) {
                return Promise.resolve(self);
            } else if (state === CLOSED) {
                return Promise.reject('not connected');
            }
            return new Promise(function (resolve, reject) {
                NauPhone.once('ready', function (event) {
                    if (event.success) {
                        resolve(self);
                    } else {
                        reject(event.error);
                }
                });
            });
        };
        NauPhone.getVersion = function () {
            return VERSION;
        };
        NauPhone.connect = function () {
            if (state !== INITIAL) {
                //TODO: new Exception?
                throw 'websocket already connected/ing';
            }
            state = CONNECTING;
            return new Promise(function (resolve, reject) {
                ws = new WebSocket(url, 'nauphone-softphone-protocol');
                ws.onopen = resolve;
                ws.onclose = reject;
            }).then(function () {
                state = HANDSHAKE;
                ws.onopen = undefined;
                ws.onclose = function (error) {
                    state = CLOSED;
                    NauPhone.emitter.emit('ready', {success: false, error: error});
                };
                ws.onerror = function () {
                    //https://developer.mozilla.org/en-US/docs/WebSockets/Writing_WebSocket_client_applications#Connection_errors
                };
                ws.onmessage = onMessage;
                return makeRequest('setProtocolVersion', {protocolVersion: VERSION}).then(function () {
                    state = CONNECTED;
                    ws.onclose = function (error) {
                        state = CLOSED;
                        NauPhone.emitter.emit('disconnected', error);
                    };
                    NauPhone.emitter.emit('ready', {success: true});
                    return self;
                }).catch(function (error) {
                    ws.close();
                    throw error;
                });
            }).catch(function (error) {
                state = CLOSED;
                NauPhone.emitter.emit('ready', {success: false, error: error});
                throw error;
            });
        };
        NauPhone.disconnect = function () {
            ws.close();
        };
        NauPhone.makeRequest = function (name, params) {
            return makeRequest(name, params);
        };
        NauPhone.getUserState = function () {
            return makeRequest('getUserState');
        };
        NauPhone.setUserState = function (state, reason) {
            var params = {
                state: state
            };
            if (reason !== undefined) {
                params.reason = reason;
            }
            return makeRequest('setUserState', params);
        };
        NauPhone.getCurrentCall = function () {
            return makeRequest('getCurrentCall').then(function (message) {
                if (message.type === 'cfr')
                    return new Conference(message.id);
                else
                    return new Call(message.id);
            });
        };
        NauPhone.getCall = function (id) {
            return NauPhone.getCalls().then( function (calls) {
                for (var i = calls.length - 1; i >= 0; i--) {
                    if (calls[i].id == id)
                        return calls[i];
                };
                return Promise.reject("Unknown call");
            });

        };
        NauPhone.getCalls = function () {
            return makeRequest('getCalls').then(function (message) {
                return message.calls.filter(function (callState) {
                    return callState.type !== 'dev';
                }).map(function (callState) {
                    if (callState.type === 'cfr')
                        return new Conference(callState.id);
                    else
                        return new Call(callState.id);
                });
            });
        };
        NauPhone.makeCall = function (number) {
            return makeRequest('makeCall', {url: number});
        };
        NauPhone.createConference = function (name) {
            return makeRequest('createConference', {conferenceName: name});
        };
        NauPhone.getConferenceCalls = function (id) {
            return makeRequest('getConferenceCalls', {id: id});
        };
        NauPhone.getPageUrls = function () {
            return makeRequest('getPageUrls');
        };
        NauPhone.bindNumber = function (number, replace) {
            params = {number: number}
            if (typeof replace !== "undefined")
                params['replace'] = replace;
            return makeRequest('bindNumber', params);
        };
        NauPhone.setActive = function (id) {
            return makeRequest('setActive', {id: id});
        };
        return NauPhone;
    }