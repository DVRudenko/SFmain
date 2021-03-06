!function(e, t) {
    "object" == typeof exports && "undefined" != typeof module ? t(require("jquery")) : "function" == typeof define && define.amd ? define(["jquery"], t) : t(e.jQuery)
}(this, function(e) {
    "use strict";
    function t(e) {
        return function(t) {
            if (0 === t.length)
                return !1;
            if (1 === t.length)
                return !0;
            var n = e(t[0].value);
            return 0 === t.filter(function(t) {
                return 0 !== e(t.value).indexOf(n)
            }).length
        }
    }
    function n(e, t) {
        return function(n, i) {
            var s, o = [];
            return t(i) && (s = C.splitTokens(C.split(n, e)),
            h.each(i, function(t, i) {
                var a = t.value;
                if (C.stringEncloses(n, a))
                    return !1;
                var r = C.splitTokens(C.split(a, e));
                0 === h.minus(s, r).length && o.push(i)
            })),
            1 === o.length ? o[0] : -1
        }
    }
    function i(e, t) {
        var n = e.data && e.data[t];
        return n && new RegExp("^" + C.escapeRegExChars(n) + "([" + x + "]|$)","i").test(e.value)
    }
    function s(e, t) {
        var n = /<strong>/;
        return n.test(t) && !n.test(e) ? t : e
    }
    function o(e, t, n, i, o) {
        var a = this;
        return s(a.highlightMatches(e, n, i, o), a.highlightMatches(t, n, i, o))
    }
    function a(t, n) {
        var i = this;
        i.element = t,
        i.el = e(t),
        i.suggestions = [],
        i.badQueries = [],
        i.selectedIndex = -1,
        i.currentValue = i.element.value,
        i.intervalId = 0,
        i.cachedResponse = {},
        i.enrichmentCache = {},
        i.currentRequest = null,
        i.inputPhase = e.Deferred(),
        i.fetchPhase = e.Deferred(),
        i.enrichPhase = e.Deferred(),
        i.onChangeTimeout = null,
        i.triggering = {},
        i.$wrapper = null,
        i.options = e.extend({}, j, n),
        i.classes = b,
        i.disabled = !1,
        i.selection = null,
        i.$viewport = e(window),
        i.$body = e(document.body),
        i.type = null,
        i.status = {},
        i.setupElement(),
        i.initializer = e.Deferred(),
        i.el.is(":visible") ? i.initializer.resolve() : i.deferInitialization(),
        i.initializer.done(e.proxy(i.initialize, i))
    }
    function r() {
        T.each(H, function(e) {
            e.abort()
        }),
        H = {}
    }
    function u() {
        K = null,
        j.geoLocation = G
    }
    function l(t) {
        return e.map(t, function(e) {
            var t = T.escapeHtml(e.text);
            return t && e.matched && (t = "<strong>" + t + "</strong>"),
            t
        }).join("")
    }
    function c(t, n) {
        var i = t.split(", ");
        return 1 === i.length ? t : e.map(i, function(e) {
            return '<span class="' + n + '">' + e + "</span>"
        }).join(", ")
    }
    function d(t, n) {
        var i = !1;
        return e.each(t, function(e, t) {
            if (i = t.value == n.value && t != n)
                return !1
        }),
        i
    }
    function f(e, t) {
        var n = t.selection
          , i = n && n.data && t.bounds;
        return i && h.each(t.bounds.all, function(t, s) {
            return i = n.data[t] === e.data[t]
        }),
        i
    }
    function p(e) {
        var t = e.replace(/^(\d{2})(\d*?)(0+)$/g, "$1$2")
          , n = t.length
          , i = -1;
        return n <= 2 ? i = 2 : n > 2 && n <= 5 ? i = 5 : n > 5 && n <= 8 ? i = 8 : n > 8 && n <= 11 ? i = 11 : n > 11 && n <= 15 ? i = 15 : n > 15 && (i = 19),
        C.padEnd(t, i, "0")
    }
    e = e && "default"in e ? e.default : e;
    var g = {
        isArray: function(e) {
            return Array.isArray(e)
        },
        isFunction: function(e) {
            return "[object Function]" === Object.prototype.toString.call(e)
        },
        isEmptyObject: function(e) {
            return 0 === Object.keys(e).length && e.constructor === Object
        },
        isPlainObject: function(e) {
            return void 0 !== e && "object" == typeof e && null !== e && !e.nodeType && e !== e.window && !(e.constructor && !Object.prototype.hasOwnProperty.call(e.constructor.prototype, "isPrototypeOf"))
        }
    }
      , h = {
        compact: function(e) {
            return e.filter(function(e) {
                return !!e
            })
        },
        each: function(e, t) {
            if (Array.isArray(e))
                return void e.some(function(e, n) {
                    return !1 === t(e, n)
                });
            Object.keys(e).some(function(n) {
                var i = e[n];
                return !1 === t(i, n)
            })
        },
        intersect: function(e, t) {
            var n = [];
            return Array.isArray(e) && Array.isArray(t) ? e.filter(function(e) {
                return -1 !== t.indexOf(e)
            }) : n
        },
        minus: function(e, t) {
            return t && 0 !== t.length ? e.filter(function(e) {
                return -1 === t.indexOf(e)
            }) : e
        },
        makeArray: function(e) {
            return g.isArray(e) ? Array.prototype.slice.call(e) : [e]
        },
        minusWithPartialMatching: function(e, t) {
            return t && 0 !== t.length ? e.filter(function(e) {
                return !t.some(function(t) {
                    return 0 === t.indexOf(e)
                })
            }) : e
        },
        slice: function(e, t) {
            return Array.prototype.slice.call(e, t)
        }
    }
      , m = {
        delay: function(e, t) {
            return setTimeout(e, t || 0)
        }
    }
      , y = {
        areSame: function e(t, n) {
            var i = !0;
            return typeof t == typeof n && ("object" == typeof t && null != t && null != n ? (h.each(t, function(t, s) {
                return i = e(t, n[s])
            }),
            i) : t === n)
        },
        assign: function(e, t) {
            if ("function" == typeof Object.assign)
                return Object.assign.apply(null, arguments);
            if (null == e)
                throw new TypeError("Cannot convert undefined or null to object");
            for (var n = Object(e), i = 1; i < arguments.length; i++) {
                var s = arguments[i];
                if (null != s)
                    for (var o in s)
                        Object.prototype.hasOwnProperty.call(s, o) && (n[o] = s[o])
            }
            return n
        },
        clone: function(e) {
            return JSON.parse(JSON.stringify(e))
        },
        compact: function(e) {
            var t = y.clone(e);
            return h.each(t, function(e, n) {
                null !== e && void 0 !== e && "" !== e || delete t[n]
            }),
            t
        },
        fieldsAreNotEmpty: function(e, t) {
            if (!g.isPlainObject(e))
                return !1;
            var n = !0;
            return h.each(t, function(t, i) {
                return n = !!e[t]
            }),
            n
        },
        getDeepValue: function e(t, n) {
            var i = n.split(".")
              , s = i.shift();
            return t && (i.length ? e(t[s], i.join(".")) : t[s])
        },
        indexObjectsById: function(e, t, n) {
            var i = {};
            return h.each(e, function(e, s) {
                var o = e[t]
                  , a = {};
                n && (a[n] = s),
                i[o] = y.assign(a, e)
            }),
            i
        }
    }
      , v = {
        ENTER: 13,
        ESC: 27,
        TAB: 9,
        SPACE: 32,
        UP: 38,
        DOWN: 40
    }
      , b = {
        hint: "suggestions-hint",
        mobile: "suggestions-mobile",
        nowrap: "suggestions-nowrap",
        promo: "suggestions-promo",
        selected: "suggestions-selected",
        suggestion: "suggestions-suggestion",
        subtext: "suggestions-subtext",
        subtext_inline: "suggestions-subtext suggestions-subtext_inline",
        subtext_delimiter: "suggestions-subtext-delimiter",
        subtext_label: "suggestions-subtext suggestions-subtext_label",
        removeConstraint: "suggestions-remove",
        value: "suggestions-value"
    }
      , _ = ".suggestions"
      , x = "\\s\"'~\\*\\.,:\\|\\[\\]\\(\\)\\{\\}<>???"
      , S = new RegExp("[" + x + "]+","g")
      , w = new RegExp("[\\-\\+\\\\\\?!@#$%^&]+","g")
      , C = {
        escapeHtml: function(e) {
            var t = {
                "&": "&amp;",
                "<": "&lt;",
                ">": "&gt;",
                '"': "&quot;",
                "'": "&#x27;",
                "/": "&#x2F;"
            };
            return e && h.each(t, function(t, n) {
                e = e.replace(new RegExp(n,"g"), t)
            }),
            e
        },
        escapeRegExChars: function(e) {
            return e.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&")
        },
        formatToken: function(e) {
            return e && e.toLowerCase().replace(/[????]/g, "??")
        },
        getWordExtractorRegExp: function() {
            return new RegExp("([^" + x + "]*)([" + x + "]*)","g")
        },
        normalize: function(e, t) {
            return C.split(e, t).join(" ")
        },
        padEnd: function(e, t, n) {
            return String.prototype.padEnd ? e.padEnd(t, n) : (t >>= 0,
            n = String(void 0 !== n ? n : " "),
            e.length > t ? String(e) : (t -= e.length,
            t > n.length && (n += n.repeat(t / n.length)),
            String(e) + n.slice(0, t)))
        },
        split: function(e, t) {
            e = e.toLowerCase(),
            e = e.replace("??", "??").replace(/(\d+)([??-??]{2,})/g, "$1 $2").replace(/([??-??]+)(\d+)/g, "$1 $2");
            var n = h.compact(e.split(S))
              , i = n.pop()
              , s = h.minus(n, t);
            return s.push(i),
            s
        },
        splitTokens: function(e) {
            var t = [];
            return h.each(e, function(e, n) {
                var i = e.split(w);
                t = t.concat(h.compact(i))
            }),
            t
        },
        stringEncloses: function(e, t) {
            return e.length > t.length && -1 !== e.toLowerCase().indexOf(t.toLowerCase())
        },
        tokenize: function(e, t) {
            var n = h.compact(C.formatToken(e).split(S))
              , i = h.minus(n, t)
              , s = h.minus(n, i);
            return n = C.withSubTokens(i.concat(s))
        },
        withSubTokens: function(e) {
            var t = [];
            return h.each(e, function(e, n) {
                var i = e.split(w);
                t.push(e),
                i.length > 1 && (t = t.concat(h.compact(i)))
            }),
            t
        }
    }
      , E = {
        Deferred: function() {
            return e.Deferred()
        },
        ajax: function(t) {
            return e.ajax(t)
        },
        extend: function() {
            return e.extend.apply(null, arguments)
        },
        isJqObject: function(t) {
            return t instanceof e
        },
        param: function(t) {
            return e.param(t)
        },
        proxy: function(t, n) {
            return e.proxy(t, n)
        },
        select: function(t) {
            return e(t)
        },
        supportsCors: function() {
            return e.support.cors
        }
    }
      , k = {
        getDefaultType: function() {
            return E.supportsCors() ? "POST" : "GET"
        },
        getDefaultContentType: function() {
            return E.supportsCors() ? "application/json" : "application/x-www-form-urlencoded"
        },
        fixURLProtocol: function(e) {
            return E.supportsCors() ? e : e.replace(/^https?:/, location.protocol)
        },
        addUrlParams: function(e, t) {
            return e + (/\?/.test(e) ? "&" : "?") + E.param(t)
        },
        serialize: function(e) {
            return E.supportsCors() ? JSON.stringify(e, function(e, t) {
                return null === t ? void 0 : t
            }) : (e = y.compact(e),
            E.param(e, !0))
        }
    }
      , P = function() {
        var e = 0;
        return function(t) {
            return (t || "") + ++e
        }
    }()
      , T = {
        escapeRegExChars: C.escapeRegExChars,
        escapeHtml: C.escapeHtml,
        formatToken: C.formatToken,
        normalize: C.normalize,
        reWordExtractor: C.getWordExtractorRegExp,
        stringEncloses: C.stringEncloses,
        addUrlParams: k.addUrlParams,
        getDefaultContentType: k.getDefaultContentType,
        getDefaultType: k.getDefaultType,
        fixURLProtocol: k.fixURLProtocol,
        serialize: k.serialize,
        arrayMinus: h.minus,
        arrayMinusWithPartialMatching: h.minusWithPartialMatching,
        arraysIntersection: h.intersect,
        compact: h.compact,
        each: h.each,
        makeArray: h.makeArray,
        slice: h.slice,
        delay: m.delay,
        areSame: y.areSame,
        compactObject: y.compact,
        getDeepValue: y.getDeepValue,
        fieldsNotEmpty: y.fieldsAreNotEmpty,
        indexBy: y.indexObjectsById,
        isArray: g.isArray,
        isEmptyObject: g.isEmptyObject,
        isFunction: g.isFunction,
        isPlainObject: g.isPlainObject,
        uniqueId: P
    }
      , j = {
        autoSelectFirst: !1,
        serviceUrl: "https://suggestions.dadata.ru/suggestions/api/4_1/rs",
        url: null,
        onSearchStart: e.noop,
        onSearchComplete: e.noop,
        onSearchError: e.noop,
        onSuggestionsFetch: null,
        onSelect: null,
        onSelectNothing: null,
        onInvalidateSelection: null,
        minChars: 1,
        deferRequestBy: 100,
        enrichmentEnabled: !0,
        params: {},
        paramName: "query",
        timeout: 3e3,
        formatResult: null,
        formatSelected: null,
        noCache: !1,
        containerClass: "suggestions-suggestions",
        tabDisabled: !1,
        triggerSelectOnSpace: !1,
        triggerSelectOnEnter: !0,
        triggerSelectOnBlur: !0,
        preventBadQueries: !1,
        hint: "???????????????? ?????????????? ?????? ???????????????????? ????????",
        noSuggestionsHint: null,
        type: null,
        requestMode: "suggest",
        count: 5,
        $helpers: null,
        headers: null,
        scrollOnFocus: !0,
        mobileWidth: 980,
        initializeInterval: 100
    }
      , V = t(function(e) {
        return e
    })
      , O = t(function(e) {
        return e.replace(/, (?:??|????|????????|??) .+$/, "")
    })
      , B = {
        matchByNormalizedQuery: function(e) {
            return function(t, n) {
                var i = C.normalize(t, e)
                  , s = [];
                return h.each(n, function(n, o) {
                    var a = n.value.toLowerCase();
                    return !C.stringEncloses(t, a) && (!(a.indexOf(i) > 0) && void (i === C.normalize(a, e) && s.push(o)))
                }),
                1 === s.length ? s[0] : -1
            }
        },
        matchByWords: function(e) {
            return n(e, V)
        },
        matchByWordsAddress: function(e) {
            return n(e, O)
        },
        matchByFields: function(e) {
            return function(t, n) {
                var i = C.splitTokens(C.split(t))
                  , s = [];
                return 1 === n.length && (e && h.each(e, function(e, t) {
                    var i = y.getDeepValue(n[0], t)
                      , o = i && C.splitTokens(C.split(i, e));
                    o && o.length && (s = s.concat(o))
                }),
                0 === h.minusWithPartialMatching(i, s).length) ? 0 : -1
            }
        }
    }
      , L = ["????", "????????", "??????", "????????", "??/??", "??????", "????????????????????", "??????????", "??????????", "??????", "??-??", "??????????", "??????????", "??????", "????", "??????????????", "??????????", "??????????", "??", "??????????????", "??????", "??", "????????", "??????", "??????", "????", "??/??_??????????", "??/??_????????????", "??/??_????", "??/??_??????????", "??/??_????????", "??/??_??????", "??/??_????", "??????????????", "????????????????", "????", "??????????", "????????????", "????????", "??", "??????????????", "??????????", "????", "????-??", "????", "????????????", "????????", "????????????", "????????", "????", "????????", "??????????", "??????", "??", "????????????", "??????????????????", "??????", "????????", "??/??", "??????", "????", "??????", "??????????", "????????????", "????", "??", "??/??", "??/??", "??/????", "????????", "??????", "??????", "??????????????", "????", "????-????", "??????????", "????????????", "????????????????????", "??????????????", "????-????", "????????????", "????????????????", "????????????", "??????????????", "????????????????", "????????????", "??????????????", "??????????????", "??-??", "??????", "????????????", "????", "????????", "??", "??/??", "??/????", "??/??", "??/??", "??/??", "??????", "??????????", "????", "??????", "??????????", "????", "????-????", "??????", "??????", "??????????", "??????", "??", "????", "????-??", "??/??", "??????????", "??", "??", "??????????????", "????????????????", "??????????????", "??????????????-????????????????????????", "??????????", "??????????????", "????????????????????????", "????????????", "??????????????", "????????????????", "??????????????", "????????????", "??????????", "????????????????????", "????????????????", "????????????????????", "????????????????????", "??????????????", "????????????????", "??????????????????", "????????????????", "??????????????", "??????????????????", "??????????????", "????????????????", "??????????????", "??????????", "????????????????????", "????????", "??????????????????", "??????????????", "????????????????????", "??????????????", "??????????????", "????????????????", "????????????????????", "??????????", "??????????", "????????", "??????????????", "??????????", "??????????"]
      , D = [{
        id: "kladr_id",
        fields: ["kladr_id"],
        forBounds: !1,
        forLocations: !0
    }, {
        id: "postal_code",
        fields: ["postal_code"],
        forBounds: !1,
        forLocations: !0
    }, {
        id: "country",
        fields: ["country"],
        forBounds: !1,
        forLocations: !0
    }, {
        id: "region_fias_id",
        fields: ["region_fias_id"],
        forBounds: !1,
        forLocations: !0
    }, {
        id: "region_type_full",
        fields: ["region_type_full"],
        forBounds: !1,
        forLocations: !0,
        kladrFormat: {
            digits: 2,
            zeros: 11
        },
        fiasType: "region_fias_id"
    }, {
        id: "region",
        fields: ["region", "region_type", "region_type_full", "region_with_type"],
        forBounds: !0,
        forLocations: !0,
        kladrFormat: {
            digits: 2,
            zeros: 11
        },
        fiasType: "region_fias_id"
    }, {
        id: "area_fias_id",
        fields: ["area_fias_id"],
        forBounds: !1,
        forLocations: !0
    }, {
        id: "area_type_full",
        fields: ["area_type_full"],
        forBounds: !1,
        forLocations: !0,
        kladrFormat: {
            digits: 5,
            zeros: 8
        },
        fiasType: "area_fias_id"
    }, {
        id: "area",
        fields: ["area", "area_type", "area_type_full", "area_with_type"],
        forBounds: !0,
        forLocations: !0,
        kladrFormat: {
            digits: 5,
            zeros: 8
        },
        fiasType: "area_fias_id"
    }, {
        id: "city_fias_id",
        fields: ["city_fias_id"],
        forBounds: !1,
        forLocations: !0
    }, {
        id: "city_type_full",
        fields: ["city_type_full"],
        forBounds: !1,
        forLocations: !0,
        kladrFormat: {
            digits: 8,
            zeros: 5
        },
        fiasType: "city_fias_id"
    }, {
        id: "city",
        fields: ["city", "city_type", "city_type_full", "city_with_type"],
        forBounds: !0,
        forLocations: !0,
        kladrFormat: {
            digits: 8,
            zeros: 5
        },
        fiasType: "city_fias_id"
    }, {
        id: "city_district_fias_id",
        fields: ["city_district_fias_id"],
        forBounds: !1,
        forLocations: !0
    }, {
        id: "city_district_type_full",
        fields: ["city_district_type_full"],
        forBounds: !1,
        forLocations: !0,
        kladrFormat: {
            digits: 11,
            zeros: 2
        },
        fiasType: "city_district_fias_id"
    }, {
        id: "city_district",
        fields: ["city_district", "city_district_type", "city_district_type_full", "city_district_with_type"],
        forBounds: !0,
        forLocations: !0,
        kladrFormat: {
            digits: 11,
            zeros: 2
        },
        fiasType: "city_district_fias_id"
    }, {
        id: "settlement_fias_id",
        fields: ["settlement_fias_id"],
        forBounds: !1,
        forLocations: !0
    }, {
        id: "settlement_type_full",
        fields: ["settlement_type_full"],
        forBounds: !1,
        forLocations: !0,
        kladrFormat: {
            digits: 11,
            zeros: 2
        },
        fiasType: "settlement_fias_id"
    }, {
        id: "settlement",
        fields: ["settlement", "settlement_type", "settlement_type_full", "settlement_with_type"],
        forBounds: !0,
        forLocations: !0,
        kladrFormat: {
            digits: 11,
            zeros: 2
        },
        fiasType: "settlement_fias_id"
    }, {
        id: "street_fias_id",
        fields: ["street_fias_id"],
        forBounds: !1,
        forLocations: !0
    }, {
        id: "street_type_full",
        fields: ["street_type_full"],
        forBounds: !1,
        forLocations: !0,
        kladrFormat: {
            digits: 15,
            zeros: 2
        },
        fiasType: "street_fias_id"
    }, {
        id: "street",
        fields: ["street", "street_type", "street_type_full", "street_with_type"],
        forBounds: !0,
        forLocations: !0,
        kladrFormat: {
            digits: 15,
            zeros: 2
        },
        fiasType: "street_fias_id"
    }, {
        id: "house",
        fields: ["house", "house_type", "house_type_full", "block", "block_type"],
        forBounds: !0,
        forLocations: !1,
        kladrFormat: {
            digits: 19
        }
    }]
      , R = {
        urlSuffix: "address",
        noSuggestionsHint: "?????????????????????? ??????????",
        matchers: [B.matchByNormalizedQuery(L), B.matchByWordsAddress(L)],
        dataComponents: D,
        dataComponentsById: y.indexObjectsById(D, "id", "index"),
        unformattableTokens: L,
        enrichmentEnabled: !0,
        enrichmentMethod: "suggest",
        enrichmentParams: {
            count: 1,
            locations: null,
            locations_boost: null,
            from_bound: null,
            to_bound: null
        },
        getEnrichmentQuery: function(e) {
            return e.unrestricted_value
        },
        geoEnabled: !0,
        isDataComplete: function(e) {
            var t = [this.bounds.to || "flat"]
              , n = e.data;
            return !g.isPlainObject(n) || y.fieldsAreNotEmpty(n, t)
        },
        composeValue: function(e, t) {
            var n = e.region_with_type || h.compact([e.region, e.region_type]).join(" ") || e.region_type_full
              , i = e.area_with_type || h.compact([e.area_type, e.area]).join(" ") || e.area_type_full
              , s = e.city_with_type || h.compact([e.city_type, e.city]).join(" ") || e.city_type_full
              , o = e.settlement_with_type || h.compact([e.settlement_type, e.settlement]).join(" ") || e.settlement_type_full
              , a = e.city_district_with_type || h.compact([e.city_district_type, e.city_district]).join(" ") || e.city_district_type_full
              , r = e.street_with_type || h.compact([e.street_type, e.street]).join(" ") || e.street_type_full
              , u = h.compact([e.house_type, e.house, e.block_type, e.block]).join(" ")
              , l = h.compact([e.flat_type, e.flat]).join(" ")
              , c = e.postal_box && "??/?? " + e.postal_box;
            return n === s && (n = ""),
            t && t.saveCityDistrict || (t && t.excludeCityDistrict ? a = "" : a && !e.city_district_fias_id && (a = "")),
            h.compact([n, i, s, a, o, r, u, l, c]).join(", ")
        },
        formatResult: function() {
            var e = []
              , t = !1;
            return D.forEach(function(n) {
                t && e.push(n.id),
                "city_district" === n.id && (t = !0)
            }),
            function(t, n, i, s) {
                var o, a, r, u = this, l = i.data && i.data.city_district_with_type, c = s && s.unformattableTokens, d = i.data && i.data.history_values;
                return d && d.length > 0 && (o = C.tokenize(n, c),
                a = this.type.findUnusedTokens(o, t),
                (r = this.type.getFormattedHistoryValues(a, d)) && (t += r)),
                t = u.highlightMatches(t, n, i, s),
                t = u.wrapFormattedValue(t, i),
                l && (!u.bounds.own.length || u.bounds.own.indexOf("street") >= 0) && !g.isEmptyObject(u.copyDataComponents(i.data, e)) && (t += '<div class="' + u.classes.subtext + '">' + u.highlightMatches(l, n, i) + "</div>"),
                t
            }
        }(),
        findUnusedTokens: function(e, t) {
            return e.filter(function(e) {
                return -1 === t.indexOf(e)
            })
        },
        getFormattedHistoryValues: function(e, t) {
            var n = []
              , i = "";
            return t.forEach(function(t) {
                h.each(e, function(e) {
                    if (t.toLowerCase().indexOf(e) >= 0)
                        return n.push(t),
                        !1
                })
            }),
            n.length > 0 && (i = " (????????. " + n.join(", ") + ")"),
            i
        },
        getSuggestionValue: function(e, t) {
            var n = null;
            return t.hasSameValues ? n = e.options.restrict_value ? this.getValueWithinConstraints(e, t.suggestion) : e.bounds.own.length ? this.getValueWithinBounds(e, t.suggestion) : t.suggestion.unrestricted_value : t.hasBeenEnriched && e.options.restrict_value && (n = this.getValueWithinConstraints(e, t.suggestion, {
                excludeCityDistrict: !0
            })),
            n
        },
        getValueWithinConstraints: function(e, t, n) {
            return this.composeValue(e.getUnrestrictedData(t.data), n)
        },
        getValueWithinBounds: function(e, t, n) {
            var i = e.copyDataComponents(t.data, e.bounds.own.concat(["city_district_fias_id"]));
            return this.composeValue(i, n)
        }
    }
      , I = {
        urlSuffix: "fio",
        noSuggestionsHint: !1,
        matchers: [B.matchByNormalizedQuery(), B.matchByWords()],
        fieldNames: {
            surname: "??????????????",
            name: "??????",
            patronymic: "????????????????"
        },
        isDataComplete: function(e) {
            var t, n = this, s = n.options.params, o = e.data;
            return g.isFunction(s) && (s = s.call(n.element, e.value)),
            s && s.parts ? t = s.parts.map(function(e) {
                return e.toLowerCase()
            }) : (t = ["surname", "name"],
            i(e, "surname") && t.push("patronymic")),
            y.fieldsAreNotEmpty(o, t)
        },
        composeValue: function(e) {
            return h.compact([e.surname, e.name, e.patronymic]).join(" ")
        }
    }
      , $ = {
        LEGAL: [2, 2, 5, 1],
        INDIVIDUAL: [2, 2, 6, 2]
    }
      , F = {
        urlSuffix: "party",
        noSuggestionsHint: "?????????????????????? ??????????????????????",
        matchers: [B.matchByFields({
            value: null,
            "data.address.value": L,
            "data.inn": null,
            "data.ogrn": null
        })],
        dataComponents: D,
        enrichmentEnabled: !0,
        enrichmentMethod: "findById",
        enrichmentParams: {
            count: 1,
            locations_boost: null
        },
        getEnrichmentQuery: function(e) {
            return e.data.hid
        },
        geoEnabled: !0,
        formatResult: function(e, t, n, i) {
            var a = this
              , r = a.type.formatResultInn.call(a, n, t)
              , u = a.highlightMatches(y.getDeepValue(n.data, "ogrn"), t, n)
              , l = s(r, u)
              , c = a.highlightMatches(y.getDeepValue(n.data, "management.name"), t, n)
              , d = y.getDeepValue(n.data, "address.value") || "";
            return a.isMobile && ((i || (i = {})).maxLength = 50),
            e = o.call(a, e, y.getDeepValue(n.data, "name.latin"), t, n, i),
            e = a.wrapFormattedValue(e, n),
            d && (d = d.replace(/^(\d{6}?\s+|????????????,\s+)/i, ""),
            d = a.isMobile ? d.replace(new RegExp("^([^" + x + "]+[" + x + "]+[^" + x + "]+).*"), "$1") : a.highlightMatches(d, t, n, {
                unformattableTokens: L
            })),
            (l || d || c) && (e += '<div class="' + a.classes.subtext + '"><span class="' + a.classes.subtext_inline + '">' + (l || "") + "</span>" + (s(d, c) || "") + "</div>"),
            e
        },
        formatResultInn: function(e, t) {
            var n, i, s = this, o = e.data && e.data.inn, a = $[e.data && e.data.type], r = /\d/;
            if (o)
                return i = s.highlightMatches(o, t, e),
                a && (i = i.split(""),
                n = a.map(function(e) {
                    for (var t, n = ""; e && (t = i.shift()); )
                        n += t,
                        r.test(t) && e--;
                    return n
                }),
                i = n.join('<span class="' + s.classes.subtext_delimiter + '"></span>') + i.join("")),
                i
        }
    }
      , q = {
        urlSuffix: "email",
        noSuggestionsHint: !1,
        matchers: [B.matchByNormalizedQuery()],
        isQueryRequestable: function(e) {
            return this.options.suggest_local || e.indexOf("@") >= 0
        }
    }
      , A = {
        urlSuffix: "bank",
        noSuggestionsHint: "?????????????????????? ????????",
        matchers: [B.matchByFields({
            value: null,
            "data.bic": null,
            "data.swift": null
        })],
        dataComponents: D,
        geoEnabled: !0,
        formatResult: function(e, t, n, i) {
            var s = this
              , o = s.highlightMatches(y.getDeepValue(n.data, "bic"), t, n)
              , a = y.getDeepValue(n.data, "address.value") || "";
            return e = s.highlightMatches(e, t, n, i),
            e = s.wrapFormattedValue(e, n),
            a && (a = a.replace(/^\d{6}( ????????????)?, /i, ""),
            a = s.isMobile ? a.replace(new RegExp("^([^" + x + "]+[" + x + "]+[^" + x + "]+).*"), "$1") : s.highlightMatches(a, t, n, {
                unformattableTokens: L
            })),
            (o || a) && (e += '<div class="' + s.classes.subtext + '"><span class="' + s.classes.subtext_inline + '">' + o + "</span>" + a + "</div>"),
            e
        },
        formatSelected: function(e) {
            return y.getDeepValue(e, "data.name.payment") || null
        }
    }
      , z = {
        NAME: I,
        ADDRESS: R,
        PARTY: F,
        EMAIL: q,
        BANK: A
    };
    E.extend(j, {
        suggest_local: !0
    });
    var M = {
        chains: {},
        on: function(e, t) {
            return this.get(e).push(t),
            this
        },
        get: function(e) {
            var t = this.chains;
            return t[e] || (t[e] = [])
        }
    }
      , N = {
        suggest: {
            defaultParams: {
                type: T.getDefaultType(),
                dataType: "json",
                contentType: T.getDefaultContentType()
            },
            addTypeInUrl: !0
        },
        detectAddressByIp: {
            defaultParams: {
                type: "GET",
                dataType: "json"
            },
            addTypeInUrl: !1
        },
        status: {
            defaultParams: {
                type: "GET",
                dataType: "json"
            },
            addTypeInUrl: !0
        },
        findById: {
            defaultParams: {
                type: T.getDefaultType(),
                dataType: "json",
                contentType: T.getDefaultContentType()
            },
            addTypeInUrl: !0
        }
    }
      , U = {
        suggest: {
            method: "suggest",
            userSelect: !0,
            updateValue: !0,
            enrichmentEnabled: !0
        },
        findById: {
            method: "findById",
            userSelect: !1,
            updateValue: !1,
            enrichmentEnabled: !1
        }
    };
    a.prototype = {
        initialize: function() {
            var e = this;
            e.uniqueId = T.uniqueId("i"),
            e.createWrapper(),
            e.notify("initialize"),
            e.bindWindowEvents(),
            e.setOptions(),
            e.fixPosition()
        },
        deferInitialization: function() {
            var e, t = this, n = "mouseover focus keydown", i = function() {
                t.initializer.resolve(),
                t.enable()
            };
            t.initializer.always(function() {
                t.el.off(n, i),
                clearInterval(e)
            }),
            t.disabled = !0,
            t.el.on(n, i),
            e = setInterval(function() {
                t.el.is(":visible") && i()
            }, t.options.initializeInterval)
        },
        isInitialized: function() {
            return "resolved" === this.initializer.state()
        },
        dispose: function() {
            var e = this;
            e.initializer.reject(),
            e.notify("dispose"),
            e.el.removeData("suggestions").removeClass("suggestions-input"),
            e.unbindWindowEvents(),
            e.removeWrapper(),
            e.el.trigger("suggestions-dispose")
        },
        notify: function(t) {
            var n = this
              , i = T.slice(arguments, 1);
            return e.map(M.get(t), function(e) {
                return e.apply(n, i)
            })
        },
        createWrapper: function() {
            var t = this;
            t.$wrapper = e('<div class="suggestions-wrapper"/>'),
            t.el.after(t.$wrapper),
            t.$wrapper.on("mousedown" + _, e.proxy(t.onMousedown, t))
        },
        removeWrapper: function() {
            var t = this;
            t.$wrapper && t.$wrapper.remove(),
            e(t.options.$helpers).off(_)
        },
        onMousedown: function(t) {
            var n = this;
            t.preventDefault(),
            n.cancelBlur = !0,
            T.delay(function() {
                delete n.cancelBlur
            }),
            0 == e(t.target).closest(".ui-menu-item").length && T.delay(function() {
                e(document).one("mousedown", function(t) {
                    var i = n.el.add(n.$wrapper).add(n.options.$helpers);
                    n.options.floating && (i = i.add(n.$container)),
                    i = i.filter(function() {
                        return this === t.target || e.contains(this, t.target)
                    }),
                    i.length || n.hide()
                })
            })
        },
        bindWindowEvents: function() {
            var t = this
              , n = e.proxy(t.fixPosition, t);
            t.$viewport.on("resize" + _ + t.uniqueId, n).on("scroll" + _ + t.uniqueId, n)
        },
        unbindWindowEvents: function() {
            this.$viewport.off("resize" + _ + this.uniqueId).off("scroll" + _ + this.uniqueId)
        },
        scrollToTop: function() {
            var t = this
              , n = t.options.scrollOnFocus;
            !0 === n && (n = t.el),
            n instanceof e && n.length > 0 && e("body,html").animate({
                scrollTop: n.offset().top
            }, "fast")
        },
        setOptions: function(t) {
            var n = this;
            e.extend(n.options, t),
            e.each({
                type: z,
                requestMode: U
            }, function(t, i) {
                if (n[t] = i[n.options[t]],
                !n[t])
                    throw n.disable(),
                    "`" + t + "` option is incorrect! Must be one of: " + e.map(i, function(e, t) {
                        return '"' + t + '"'
                    }).join(", ")
            }),
            e(n.options.$helpers).off(_).on("mousedown" + _, e.proxy(n.onMousedown, n)),
            n.isInitialized() && n.notify("setOptions")
        },
        fixPosition: function(t) {
            var n, i, s = this, o = {};
            s.isMobile = s.$viewport.width() + 2 <= s.options.mobileWidth,
            s.isInitialized() && (!t || "scroll" != t.type || s.options.floating || s.isMobile) && (s.$container.appendTo(s.options.floating ? s.$body : s.$wrapper),
            s.notify("resetPosition"),
            s.el.css("paddingLeft", ""),
            s.el.css("paddingRight", ""),
            o.paddingLeft = parseFloat(s.el.css("paddingLeft")),
            o.paddingRight = parseFloat(s.el.css("paddingRight")),
            e.extend(o, s.el.offset()),
            o.borderTop = "none" == s.el.css("border-top-style") ? 0 : parseFloat(s.el.css("border-top-width")),
            o.borderLeft = "none" == s.el.css("border-left-style") ? 0 : parseFloat(s.el.css("border-left-width")),
            o.innerHeight = s.el.innerHeight(),
            o.innerWidth = s.el.innerWidth(),
            o.outerHeight = s.el.outerHeight(),
            o.componentsLeft = 0,
            o.componentsRight = 0,
            n = s.$wrapper.offset(),
            i = {
                top: o.top - n.top,
                left: o.left - n.left
            },
            s.notify("fixPosition", i, o),
            o.componentsLeft > o.paddingLeft && s.el.css("paddingLeft", o.componentsLeft + "px"),
            o.componentsRight > o.paddingRight && s.el.css("paddingRight", o.componentsRight + "px"))
        },
        clearCache: function() {
            this.cachedResponse = {},
            this.enrichmentCache = {},
            this.badQueries = []
        },
        clear: function() {
            var e = this
              , t = e.selection;
            e.isInitialized() && (e.clearCache(),
            e.currentValue = "",
            e.selection = null,
            e.hide(),
            e.suggestions = [],
            e.el.val(""),
            e.el.trigger("suggestions-clear"),
            e.notify("clear"),
            e.trigger("InvalidateSelection", t))
        },
        disable: function() {
            var e = this;
            e.disabled = !0,
            e.abortRequest(),
            e.visible && e.hide()
        },
        enable: function() {
            this.disabled = !1
        },
        isUnavailable: function() {
            return this.disabled
        },
        update: function() {
            var e = this
              , t = e.el.val();
            e.isInitialized() && (e.currentValue = t,
            e.isQueryRequestable(t) ? e.updateSuggestions(t) : e.hide())
        },
        setSuggestion: function(t) {
            var n, i, s = this;
            e.isPlainObject(t) && e.isPlainObject(t.data) && (t = e.extend(!0, {}, t),
            s.isUnavailable() && s.initializer && "pending" === s.initializer.state() && (s.initializer.resolve(),
            s.enable()),
            s.bounds.own.length && (s.checkValueBounds(t),
            n = s.copyDataComponents(t.data, s.bounds.all),
            t.data.kladr_id && (n.kladr_id = s.getBoundedKladrId(t.data.kladr_id, s.bounds.all)),
            t.data = n),
            s.selection = t,
            s.suggestions = [t],
            i = s.getSuggestionValue(t) || "",
            s.currentValue = i,
            s.el.val(i),
            s.abortRequest(),
            s.el.trigger("suggestions-set"))
        },
        fixData: function() {
            var t = this
              , n = t.extendedCurrentValue()
              , i = t.el.val()
              , s = e.Deferred();
            s.done(function(e) {
                t.selectSuggestion(e, 0, i, {
                    hasBeenEnriched: !0
                }),
                t.el.trigger("suggestions-fixdata", e)
            }).fail(function() {
                t.selection = null,
                t.el.trigger("suggestions-fixdata")
            }),
            t.isQueryRequestable(n) ? (t.currentValue = n,
            t.getSuggestions(n, {
                count: 1,
                from_bound: null,
                to_bound: null
            }).done(function(e) {
                var t = e[0];
                t ? s.resolve(t) : s.reject()
            }).fail(function() {
                s.reject()
            })) : s.reject()
        },
        extendedCurrentValue: function() {
            var t = this
              , n = t.getParentInstance()
              , i = n && n.extendedCurrentValue()
              , s = e.trim(t.el.val());
            return T.compact([i, s]).join(" ")
        },
        getAjaxParams: function(t, n) {
            var i = this
              , s = e.trim(i.options.token)
              , o = e.trim(i.options.partner)
              , r = i.options.serviceUrl
              , u = i.options.url
              , l = N[t]
              , c = e.extend({
                timeout: i.options.timeout
            }, l.defaultParams)
              , d = {};
            return u ? r = u : (/\/$/.test(r) || (r += "/"),
            r += t,
            l.addTypeInUrl && (r += "/" + i.type.urlSuffix)),
            r = T.fixURLProtocol(r),
            e.support.cors ? (s && (d.Authorization = "Token " + s),
            o && (d["X-Partner"] = o),
            d["X-Version"] = a.version,
            c.headers || (c.headers = {}),
            c.xhrFields || (c.xhrFields = {}),
            e.extend(c.headers, i.options.headers, d),
            c.xhrFields.withCredentials = !1) : (s && (d.token = s),
            o && (d.partner = o),
            d.version = a.version,
            r = T.addUrlParams(r, d)),
            c.url = r,
            e.extend(c, n)
        },
        isQueryRequestable: function(e) {
            var t, n = this;
            return t = e.length >= n.options.minChars,
            t && n.type.isQueryRequestable && (t = n.type.isQueryRequestable.call(n, e)),
            t
        },
        constructRequestParams: function(t, n) {
            var i = this
              , s = i.options
              , o = e.isFunction(s.params) ? s.params.call(i.element, t) : e.extend({}, s.params);
            return i.type.constructRequestParams && e.extend(o, i.type.constructRequestParams.call(i)),
            e.each(i.notify("requestParams"), function(t, n) {
                e.extend(o, n)
            }),
            o[s.paramName] = t,
            e.isNumeric(s.count) && s.count > 0 && (o.count = s.count),
            e.extend(o, n)
        },
        updateSuggestions: function(e) {
            var t = this;
            t.fetchPhase = t.getSuggestions(e).done(function(n) {
                t.assignSuggestions(n, e)
            })
        },
        getSuggestions: function(t, n, i) {
            var s, o = this, a = o.options, r = i && i.noCallbacks, u = i && i.useEnrichmentCache, l = i && i.method || o.requestMode.method, c = o.constructRequestParams(t, n), d = e.param(c || {}), f = e.Deferred();
            return s = o.cachedResponse[d],
            s && e.isArray(s.suggestions) ? f.resolve(s.suggestions) : o.isBadQuery(t) ? f.reject() : r || !1 !== a.onSearchStart.call(o.element, c) ? o.doGetSuggestions(c, l).done(function(e) {
                o.processResponse(e) && t == o.currentValue ? (a.noCache || (u ? o.enrichmentCache[t] = e.suggestions[0] : (o.enrichResponse(e, t),
                o.cachedResponse[d] = e,
                a.preventBadQueries && 0 === e.suggestions.length && o.badQueries.push(t))),
                f.resolve(e.suggestions)) : f.reject(),
                r || a.onSearchComplete.call(o.element, t, e.suggestions)
            }).fail(function(e, n, i) {
                f.reject(),
                r || "abort" === n || a.onSearchError.call(o.element, t, e, n, i)
            }) : f.reject(),
            f
        },
        doGetSuggestions: function(t, n) {
            var i = this
              , s = e.ajax(i.getAjaxParams(n, {
                data: T.serialize(t)
            }));
            return i.abortRequest(),
            i.currentRequest = s,
            i.notify("request"),
            s.always(function() {
                i.currentRequest = null,
                i.notify("request")
            }),
            s
        },
        isBadQuery: function(t) {
            if (!this.options.preventBadQueries)
                return !1;
            var n = !1;
            return e.each(this.badQueries, function(e, i) {
                return !(n = 0 === t.indexOf(i))
            }),
            n
        },
        abortRequest: function() {
            var e = this;
            e.currentRequest && e.currentRequest.abort()
        },
        processResponse: function(t) {
            var n, i = this;
            return !(!t || !e.isArray(t.suggestions)) && (i.verifySuggestionsFormat(t.suggestions),
            i.setUnrestrictedValues(t.suggestions),
            e.isFunction(i.options.onSuggestionsFetch) && (n = i.options.onSuggestionsFetch.call(i.element, t.suggestions),
            e.isArray(n) && (t.suggestions = n)),
            !0)
        },
        verifySuggestionsFormat: function(t) {
            "string" == typeof t[0] && e.each(t, function(e, n) {
                t[e] = {
                    value: n,
                    data: null
                }
            })
        },
        getSuggestionValue: function(t, n) {
            var i, s = this, o = s.options.formatSelected || s.type.formatSelected, a = n && n.hasSameValues, r = n && n.hasBeenEnriched, u = null;
            return e.isFunction(o) && (i = o.call(s, t)),
            "string" != typeof i && (i = t.value,
            s.type.getSuggestionValue && null !== (u = s.type.getSuggestionValue(s, {
                suggestion: t,
                hasSameValues: a,
                hasBeenEnriched: r
            })) && (i = u)),
            i
        },
        hasSameValues: function(t) {
            var n = !1;
            return e.each(this.suggestions, function(e, i) {
                if (i.value === t.value && i !== t)
                    return n = !0,
                    !1
            }),
            n
        },
        assignSuggestions: function(e, t) {
            var n = this;
            n.suggestions = e,
            n.notify("assignSuggestions", t)
        },
        shouldRestrictValues: function() {
            var e = this;
            return e.options.restrict_value && e.constraints && 1 == Object.keys(e.constraints).length
        },
        setUnrestrictedValues: function(t) {
            var n = this
              , i = n.shouldRestrictValues()
              , s = n.getFirstConstraintLabel();
            e.each(t, function(e, t) {
                t.unrestricted_value || (t.unrestricted_value = i ? s + ", " + t.value : t.value)
            })
        },
        areSuggestionsSame: function(e, t) {
            return e && t && e.value === t.value && T.areSame(e.data, t.data)
        },
        getNoSuggestionsHint: function() {
            var e = this;
            return !1 !== e.options.noSuggestionsHint && (e.options.noSuggestionsHint || e.type.noSuggestionsHint)
        }
    };
    var W = {
        setupElement: function() {
            this.el.attr("autocomplete", "off").attr("autocorrect", "off").attr("autocapitalize", "off").attr("spellcheck", "false").addClass("suggestions-input").css("box-sizing", "border-box")
        },
        bindElementEvents: function() {
            var t = this;
            t.el.on("keydown" + _, e.proxy(t.onElementKeyDown, t)),
            t.el.on(["keyup" + _, "cut" + _, "paste" + _, "input" + _].join(" "), e.proxy(t.onElementKeyUp, t)),
            t.el.on("blur" + _, e.proxy(t.onElementBlur, t)),
            t.el.on("focus" + _, e.proxy(t.onElementFocus, t))
        },
        unbindElementEvents: function() {
            this.el.off(_)
        },
        onElementBlur: function() {
            var e = this;
            if (e.cancelBlur)
                return void (e.cancelBlur = !1);
            e.options.triggerSelectOnBlur ? e.isUnavailable() || e.selectCurrentValue({
                noSpace: !0
            }).always(function() {
                e.hide()
            }) : e.hide(),
            e.fetchPhase.abort && e.fetchPhase.abort()
        },
        onElementFocus: function() {
            var t = this;
            t.cancelFocus || T.delay(e.proxy(t.completeOnFocus, t)),
            t.cancelFocus = !1
        },
        onElementKeyDown: function(e) {
            var t = this;
            if (!t.isUnavailable())
                if (t.visible) {
                    switch (e.which) {
                    case v.ESC:
                        t.el.val(t.currentValue),
                        t.hide(),
                        t.abortRequest();
                        break;
                    case v.TAB:
                        if (!1 === t.options.tabDisabled)
                            return;
                        break;
                    case v.ENTER:
                        t.options.triggerSelectOnEnter && t.selectCurrentValue();
                        break;
                    case v.SPACE:
                        return void (t.options.triggerSelectOnSpace && t.isCursorAtEnd() && (e.preventDefault(),
                        t.selectCurrentValue({
                            continueSelecting: !0,
                            dontEnrich: !0
                        }).fail(function() {
                            t.currentValue += " ",
                            t.el.val(t.currentValue),
                            t.proceedChangedValue()
                        })));
                    case v.UP:
                        t.moveUp();
                        break;
                    case v.DOWN:
                        t.moveDown();
                        break;
                    default:
                        return
                    }
                    e.stopImmediatePropagation(),
                    e.preventDefault()
                } else
                    switch (e.which) {
                    case v.DOWN:
                        t.suggest();
                        break;
                    case v.ENTER:
                        t.options.triggerSelectOnEnter && t.triggerOnSelectNothing()
                    }
        },
        onElementKeyUp: function(e) {
            var t = this;
            if (!t.isUnavailable()) {
                switch (e.which) {
                case v.UP:
                case v.DOWN:
                case v.ENTER:
                    return
                }
                clearTimeout(t.onChangeTimeout),
                t.inputPhase.reject(),
                t.currentValue !== t.el.val() && t.proceedChangedValue()
            }
        },
        proceedChangedValue: function() {
            var t = this;
            t.abortRequest(),
            t.inputPhase = e.Deferred().done(e.proxy(t.onValueChange, t)),
            t.options.deferRequestBy > 0 ? t.onChangeTimeout = T.delay(function() {
                t.inputPhase.resolve()
            }, t.options.deferRequestBy) : t.inputPhase.resolve()
        },
        onValueChange: function() {
            var e, t = this;
            t.selection && (e = t.selection,
            t.selection = null,
            t.trigger("InvalidateSelection", e)),
            t.selectedIndex = -1,
            t.update(),
            t.notify("valueChange")
        },
        completeOnFocus: function() {
            var e = this;
            e.isUnavailable() || e.isElementFocused() && (e.fixPosition(),
            e.update(),
            e.isMobile && (e.setCursorAtEnd(),
            e.scrollToTop()))
        },
        isElementFocused: function() {
            return document.activeElement === this.element
        },
        isElementDisabled: function() {
            return Boolean(this.element.getAttribute("disabled") || this.element.getAttribute("readonly"))
        },
        isCursorAtEnd: function() {
            var e, t, n = this, i = n.el.val().length;
            try {
                if ("number" == typeof (e = n.element.selectionStart))
                    return e === i
            } catch (e) {}
            return !document.selection || (t = document.selection.createRange(),
            t.moveStart("character", -i),
            i === t.text.length)
        },
        setCursorAtEnd: function() {
            var e = this.element;
            try {
                e.selectionEnd = e.selectionStart = e.value.length,
                e.scrollLeft = e.scrollWidth
            } catch (t) {
                e.value = e.value
            }
        }
    };
    e.extend(a.prototype, W),
    M.on("initialize", W.bindElementEvents).on("dispose", W.unbindElementEvents);
    var H = {};
    r();
    var Q = {
        checkStatus: function() {
            function e(e) {
                T.isFunction(t.options.onSearchError) && t.options.onSearchError.call(t.element, null, s, "error", e)
            }
            var t = this
              , n = t.options.token && t.options.token.trim() || ""
              , i = t.options.type + n
              , s = H[i];
            s || (s = H[i] = E.ajax(t.getAjaxParams("status"))),
            s.done(function(n) {
                n.search ? E.extend(t.status, n) : e("Service Unavailable")
            }).fail(function() {
                e(s.statusText)
            })
        }
    };
    a.resetTokens = r,
    E.extend(a.prototype, Q),
    M.on("setOptions", Q.checkStatus);
    var K, G = !0, J = {
        checkLocation: function() {
            var t = this
              , n = t.options.geoLocation;
            t.type.geoEnabled && n && (t.geoLocation = e.Deferred(),
            e.isPlainObject(n) || e.isArray(n) ? t.geoLocation.resolve(n) : (K || (K = e.ajax(t.getAjaxParams("detectAddressByIp"))),
            K.done(function(e) {
                var n = e && e.location && e.location.data;
                n && n.kladr_id ? t.geoLocation.resolve(n) : t.geoLocation.reject()
            }).fail(function() {
                t.geoLocation.reject()
            })))
        },
        getGeoLocation: function() {
            return this.geoLocation
        },
        constructParams: function() {
            var t = this
              , n = {};
            return t.geoLocation && e.isFunction(t.geoLocation.promise) && "resolved" == t.geoLocation.state() && t.geoLocation.done(function(t) {
                n.locations_boost = e.makeArray(t)
            }),
            n
        }
    };
    "GET" != T.getDefaultType() && (e.extend(j, {
        geoLocation: G
    }),
    e.extend(a, {
        resetLocation: u
    }),
    e.extend(a.prototype, {
        getGeoLocation: J.getGeoLocation
    }),
    M.on("setOptions", J.checkLocation).on("requestParams", J.constructParams));
    var X = {
        enrichSuggestion: function(t, n) {
            var i = this
              , s = e.Deferred();
            if (!i.options.enrichmentEnabled || !i.type.enrichmentEnabled || !i.requestMode.enrichmentEnabled || n && n.dontEnrich)
                return s.resolve(t);
            if (t.data && null != t.data.qc)
                return s.resolve(t);
            i.disableDropdown();
            var o = i.type.getEnrichmentQuery(t)
              , a = i.type.enrichmentParams
              , r = {
                noCallbacks: !0,
                useEnrichmentCache: !0,
                method: i.type.enrichmentMethod
            };
            return i.currentValue = o,
            i.enrichPhase = i.getSuggestions(o, a, r).always(function() {
                i.enableDropdown()
            }).done(function(e) {
                var n = e && e[0];
                s.resolve(n || t, !!n)
            }).fail(function() {
                s.resolve(t)
            }),
            s
        },
        enrichResponse: function(t, n) {
            var i = this
              , s = i.enrichmentCache[n];
            s && e.each(t.suggestions, function(e, i) {
                if (i.value === n)
                    return t.suggestions[e] = s,
                    !1
            })
        }
    };
    e.extend(a.prototype, X);
    var Y = {
        width: "auto",
        floating: !1
    }
      , Z = {
        createContainer: function() {
            var t = this
              , n = "." + t.classes.suggestion
              , i = t.options
              , s = e("<div/>").addClass(i.containerClass).css({
                position: "absolute",
                display: "none"
            });
            t.$container = s,
            s.on("click" + _, n, e.proxy(t.onSuggestionClick, t))
        },
        getContainer: function() {
            return this.$container.get(0)
        },
        removeContainer: function() {
            var e = this;
            e.options.floating && e.$container.remove()
        },
        setContainerOptions: function() {
            var t = this;
            t.$container.off("mousedown.suggestions"),
            t.options.floating && t.$container.on("mousedown.suggestions", e.proxy(t.onMousedown, t))
        },
        onSuggestionClick: function(t) {
            var n, i = this, s = e(t.target);
            if (!i.dropdownDisabled) {
                for (i.cancelFocus = !0,
                i.el.focus(); s.length && !(n = s.attr("data-index")); )
                    s = s.closest("." + i.classes.suggestion);
                n && !isNaN(n) && i.select(+n)
            }
        },
        setDropdownPosition: function(e, t) {
            var n, i = this, s = i.$viewport.scrollLeft();
            i.isMobile ? (n = i.options.floating ? {
                left: s + "px",
                top: t.top + t.outerHeight + "px"
            } : {
                left: e.left - t.left + s + "px",
                top: e.top + t.outerHeight + "px"
            },
            n.width = i.$viewport.width() + 2 + "px") : (n = i.options.floating ? {
                left: t.left + "px",
                top: t.top + t.borderTop + t.innerHeight + "px"
            } : {
                left: e.left + "px",
                top: e.top + t.borderTop + t.innerHeight + "px"
            },
            T.delay(function() {
                var e = i.options.width;
                "auto" === e && (e = i.el.outerWidth() + 2),
                i.$container.outerWidth(e)
            })),
            i.$container.toggleClass(i.classes.mobile, i.isMobile).css(n),
            i.containerItemsPadding = t.left + t.borderLeft + t.paddingLeft - s
        },
        setItemsPositions: function() {
            var e = this;
            e.getSuggestionsItems().css("paddingLeft", e.isMobile ? e.containerItemsPadding + "px" : "")
        },
        getSuggestionsItems: function() {
            return this.$container.children("." + this.classes.suggestion)
        },
        toggleDropdownEnabling: function(e) {
            this.dropdownDisabled = !e,
            this.$container.attr("disabled", !e)
        },
        disableDropdown: function() {
            this.toggleDropdownEnabling(!1)
        },
        enableDropdown: function() {
            this.toggleDropdownEnabling(!0)
        },
        hasSuggestionsToChoose: function() {
            var t = this;
            return t.suggestions.length > 1 || 1 === t.suggestions.length && (!t.selection || e.trim(t.suggestions[0].value) !== e.trim(t.selection.value))
        },
        suggest: function() {
            var t = this
              , n = t.options
              , i = [];
            if (t.requestMode.userSelect) {
                if (t.hasSuggestionsToChoose())
                    !t.isMobile && n.hint && t.suggestions.length && i.push('<div class="' + t.classes.hint + '">' + n.hint + "</div>"),
                    t.selectedIndex = -1,
                    t.suggestions.forEach(function(e, n) {
                        e == t.selection && (t.selectedIndex = n),
                        t.buildSuggestionHtml(e, n, i)
                    });
                else {
                    if (t.suggestions.length)
                        return void t.hide();
                    var s = t.getNoSuggestionsHint();
                    if (!s)
                        return void t.hide();
                    i.push('<div class="' + t.classes.hint + '">' + s + "</div>")
                }
                i.push('<div class="' + b.promo + '"></div>'),
                i.push("</div>"),
                t.$container.html(i.join("")),
                n.autoSelectFirst && -1 === t.selectedIndex && (t.selectedIndex = 0),
                -1 !== t.selectedIndex && t.getSuggestionsItems().eq(t.selectedIndex).addClass(t.classes.selected),
                e.isFunction(n.beforeRender) && n.beforeRender.call(t.element, t.$container),
                t.$container.show(),
                t.visible = !0,
                t.fixPosition(),
                t.setItemsPositions()
            }
        },
        buildSuggestionHtml: function(e, t, n) {
            n.push('<div class="' + this.classes.suggestion + '" data-index="' + t + '">');
            var i = this.options.formatResult || this.type.formatResult || this.formatResult;
            n.push(i.call(this, e.value, this.currentValue, e, {
                unformattableTokens: this.type.unformattableTokens
            }));
            var s = this.makeSuggestionLabel(this.suggestions, e);
            s && n.push('<span class="' + this.classes.subtext_label + '">' + T.escapeHtml(s) + "</span>"),
            n.push("</div>")
        },
        wrapFormattedValue: function(e, t) {
            var n = this
              , i = T.getDeepValue(t.data, "state.status");
            return '<span class="' + n.classes.value + '"' + (i ? ' data-suggestion-status="' + i + '"' : "") + ">" + e + "</span>"
        },
        formatResult: function(e, t, n, i) {
            var s = this;
            return e = s.highlightMatches(e, t, n, i),
            s.wrapFormattedValue(e, n)
        },
        highlightMatches: function(t, n, i, s) {
            var o, a, r, u, d, f, p, g = this, h = [], m = s && s.unformattableTokens, y = s && s.maxLength, v = T.reWordExtractor();
            if (!t)
                return "";
            for (o = C.tokenize(n, m),
            a = e.map(o, function(e) {
                return new RegExp("^((.*)([\\-\\+\\\\\\?!@#$%^&]+))?(" + T.escapeRegExChars(e) + ")([^\\-\\+\\\\\\?!@#$%^&]*[\\-\\+\\\\\\?!@#$%^&]*)","i")
            }); (r = v.exec(t)) && r[0]; )
                u = r[1],
                h.push({
                    text: u,
                    hasUpperCase: u.toLowerCase() !== u,
                    formatted: T.formatToken(u),
                    matchable: !0
                }),
                r[2] && h.push({
                    text: r[2]
                });
            for (d = 0; d < h.length; d++)
                f = h[d],
                !f.matchable || f.matched || -1 !== e.inArray(f.formatted, m) && !f.hasUpperCase || e.each(a, function(e, t) {
                    var n, i = t.exec(f.formatted), s = d + 1;
                    if (i)
                        return i = {
                            before: i[1] || "",
                            beforeText: i[2] || "",
                            beforeDelimiter: i[3] || "",
                            text: i[4] || "",
                            after: i[5] || ""
                        },
                        i.before && (h.splice(d, 0, {
                            text: f.text.substr(0, i.beforeText.length),
                            formatted: i.beforeText,
                            matchable: !0
                        }, {
                            text: i.beforeDelimiter
                        }),
                        s += 2,
                        n = i.before.length,
                        f.text = f.text.substr(n),
                        f.formatted = f.formatted.substr(n),
                        d--),
                        n = i.text.length + i.after.length,
                        f.formatted.length > n && (h.splice(s, 0, {
                            text: f.text.substr(n),
                            formatted: f.formatted.substr(n),
                            matchable: !0
                        }),
                        f.text = f.text.substr(0, n),
                        f.formatted = f.formatted.substr(0, n)),
                        i.after && (n = i.text.length,
                        h.splice(s, 0, {
                            text: f.text.substr(n),
                            formatted: f.formatted.substr(n)
                        }),
                        f.text = f.text.substr(0, n),
                        f.formatted = f.formatted.substr(0, n)),
                        f.matched = !0,
                        !1
                });
            if (y) {
                for (d = 0; d < h.length && y >= 0; d++)
                    f = h[d],
                    (y -= f.text.length) < 0 && (f.text = f.text.substr(0, f.text.length + y) + "...");
                h.length = d
            }
            return p = l(h),
            c(p, g.classes.nowrap)
        },
        makeSuggestionLabel: function(t, n) {
            var i, s, o = this, a = o.type.fieldNames, r = {}, u = T.reWordExtractor(), l = [];
            if (a && d(t, n) && n.data && (e.each(a, function(e) {
                var t = n.data[e];
                t && (r[e] = T.formatToken(t))
            }),
            !e.isEmptyObject(r))) {
                for (; (i = u.exec(T.formatToken(n.value))) && (s = i[1]); )
                    e.each(r, function(e, t) {
                        if (t == s)
                            return l.push(a[e]),
                            delete r[e],
                            !1
                    });
                if (l.length)
                    return l.join(", ")
            }
        },
        hide: function() {
            var e = this;
            e.visible = !1,
            e.selectedIndex = -1,
            e.$container.hide().empty()
        },
        activate: function(e) {
            var t, n, i = this, s = i.classes.selected;
            return !i.dropdownDisabled && (n = i.getSuggestionsItems(),
            n.removeClass(s),
            i.selectedIndex = e,
            -1 !== i.selectedIndex && n.length > i.selectedIndex) ? (t = n.eq(i.selectedIndex),
            t.addClass(s),
            t) : null
        },
        deactivate: function(e) {
            var t = this;
            t.dropdownDisabled || (t.selectedIndex = -1,
            t.getSuggestionsItems().removeClass(t.classes.selected),
            e && t.el.val(t.currentValue))
        },
        moveUp: function() {
            var e = this;
            if (!e.dropdownDisabled)
                return -1 === e.selectedIndex ? void (e.suggestions.length && e.adjustScroll(e.suggestions.length - 1)) : 0 === e.selectedIndex ? void e.deactivate(!0) : void e.adjustScroll(e.selectedIndex - 1)
        },
        moveDown: function() {
            var e = this;
            if (!e.dropdownDisabled)
                return e.selectedIndex === e.suggestions.length - 1 ? void e.deactivate(!0) : void e.adjustScroll(e.selectedIndex + 1)
        },
        adjustScroll: function(e) {
            var t, n, i, s = this, o = s.activate(e), a = s.$container.scrollTop();
            o && o.length && (t = o.position().top,
            t < 0 ? s.$container.scrollTop(a + t) : (n = t + o.outerHeight(),
            i = s.$container.innerHeight(),
            n > i && s.$container.scrollTop(a - i + n)),
            s.el.val(s.suggestions[e].value))
        }
    };
    e.extend(j, Y),
    e.extend(a.prototype, Z),
    M.on("initialize", Z.createContainer).on("dispose", Z.removeContainer).on("setOptions", Z.setContainerOptions).on("fixPosition", Z.setDropdownPosition).on("fixPosition", Z.setItemsPositions).on("assignSuggestions", Z.suggest);
    var ee = {
        addon: null
    }
      , te = {
        NONE: "none",
        SPINNER: "spinner",
        CLEAR: "clear"
    }
      , ne = function(e) {
        var t = E.select('<span class="suggestions-addon"/>');
        this.owner = e,
        this.$el = t,
        this.type = te.NONE,
        this.visible = !1,
        this.initialPadding = null,
        t.on("click", E.proxy(this, "onClick"))
    };
    ne.prototype = {
        checkType: function() {
            var e = this.owner.options.addon
              , t = !1;
            h.each(te, function(n, i) {
                if (t = n == e)
                    return !1
            }),
            t || (e = this.owner.isMobile ? te.CLEAR : te.SPINNER),
            e != this.type && (this.type = e,
            this.$el.attr("data-addon-type", e),
            this.toggle(!0))
        },
        isEnabled: function() {
            return !this.owner.isElementDisabled()
        },
        toggle: function(e) {
            var t;
            switch (this.type) {
            case te.CLEAR:
                t = !!this.owner.currentValue;
                break;
            case te.SPINNER:
                t = !!this.owner.currentRequest;
                break;
            default:
                t = !1
            }
            this.isEnabled() || (t = !1),
            t != this.visible && (this.visible = t,
            t ? this.show(e) : this.hide(e))
        },
        show: function(e) {
            var t = this
              , n = {
                opacity: 1
            };
            e ? (this.$el.show().css(n),
            this.showBackground(!0)) : this.$el.stop(!0, !0).delay(50).queue(function() {
                t.$el.show(),
                t.showBackground(),
                t.$el.dequeue()
            }).animate(n, "fast")
        },
        hide: function(e) {
            var t = this
              , n = {
                opacity: 0
            };
            e && this.$el.hide().css(n),
            this.$el.stop(!0).animate(n, {
                duration: "fast",
                complete: function() {
                    t.$el.hide(),
                    t.hideBackground()
                }
            })
        },
        fixPosition: function(e, t) {
            var n = t.innerHeight;
            this.checkType(),
            this.$el.css({
                left: e.left + t.borderLeft + t.innerWidth - n + "px",
                top: e.top + t.borderTop + "px",
                height: n,
                width: n + 2
            }),
            this.initialPadding = t.paddingRight,
            this.width = n + 2,
            this.visible && (t.componentsRight += n)
        },
        showBackground: function(e) {
            var t = this.owner.el
              , n = {
                paddingRight: this.width
            };
            this.width > this.initialPadding && (this.stopBackground(),
            e ? t.css(n) : t.animate(n, {
                duration: "fast",
                queue: "addon"
            }).dequeue("addon"))
        },
        hideBackground: function(e) {
            var t = this.owner.el
              , n = {
                paddingRight: this.initialPadding
            };
            this.width > this.initialPadding && (this.stopBackground(!0),
            e ? t.css(n) : t.delay(1e3, "addon").animate(n, {
                duration: "fast",
                queue: "addon"
            }).dequeue("addon"))
        },
        stopBackground: function(e) {
            this.owner.el.stop("addon", !0, e)
        },
        onClick: function(e) {
            this.isEnabled() && this.type == te.CLEAR && this.owner.clear()
        }
    };
    var ie = {
        createAddon: function() {
            var e = new ne(this);
            this.$wrapper.append(e.$el),
            this.addon = e
        },
        fixAddonPosition: function(e, t) {
            this.addon.fixPosition(e, t)
        },
        checkAddonType: function() {
            this.addon.checkType()
        },
        checkAddonVisibility: function() {
            this.addon.toggle()
        },
        stopBackground: function() {
            this.addon.stopBackground()
        }
    };
    E.extend(j, ee),
    M.on("initialize", ie.createAddon).on("setOptions", ie.checkAddonType).on("fixPosition", ie.fixAddonPosition).on("clear", ie.checkAddonVisibility).on("valueChange", ie.checkAddonVisibility).on("request", ie.checkAddonVisibility).on("resetPosition", ie.stopBackground);
    var se = {
        constraints: null,
        restrict_value: !1
    }
      , oe = ["region_fias_id", "area_fias_id", "city_fias_id", "city_district_fias_id", "settlement_fias_id", "street_fias_id"]
      , ae = function(e, t) {
        var n, i, s = this, o = {};
        s.instance = t,
        s.fields = {},
        s.specificity = -1,
        g.isPlainObject(e) && t.type.dataComponents && h.each(t.type.dataComponents, function(t, n) {
            var i = t.id;
            t.forLocations && e[i] && (s.fields[i] = e[i],
            s.specificity = n)
        }),
        n = Object.keys(s.fields),
        i = h.intersect(n, oe),
        i.length ? (h.each(i, function(e, t) {
            o[e] = s.fields[e]
        }),
        s.fields = o,
        s.specificity = s.getFiasSpecificity(i)) : s.fields.kladr_id && (s.fields = {
            kladr_id: s.fields.kladr_id
        },
        s.significantKladr = p(s.fields.kladr_id),
        s.specificity = s.getKladrSpecificity(s.significantKladr))
    };
    E.extend(ae.prototype, {
        getLabel: function() {
            return this.instance.type.composeValue(this.fields, {
                saveCityDistrict: !0
            })
        },
        getFields: function() {
            return this.fields
        },
        isValid: function() {
            return !g.isEmptyObject(this.fields)
        },
        getKladrSpecificity: function(e) {
            var t = -1
              , n = e.length;
            return h.each(this.instance.type.dataComponents, function(e, i) {
                e.kladrFormat && n === e.kladrFormat.digits && (t = i)
            }),
            t
        },
        getFiasSpecificity: function(e) {
            var t = -1;
            return h.each(this.instance.type.dataComponents, function(n, i) {
                n.fiasType && e.indexOf(n.fiasType) > -1 && t < i && (t = i)
            }),
            t
        },
        containsData: function(e) {
            var t = !0;
            return this.fields.kladr_id ? !!e.kladr_id && 0 === e.kladr_id.indexOf(this.significantKladr) : (h.each(this.fields, function(n, i) {
                return t = !!e[i] && e[i].toLowerCase() === n.toLowerCase()
            }),
            t)
        }
    }),
    a.ConstraintLocation = ae;
    var re = function(e, t) {
        this.id = P("c"),
        this.deletable = !!e.deletable,
        this.instance = t;
        var n = h.makeArray(e && (e.locations || e.restrictions));
        this.locations = n.map(function(e) {
            return new ae(e,t)
        }),
        this.locations = this.locations.filter(function(e) {
            return e.isValid()
        }),
        this.label = e.label,
        null == this.label && t.type.composeValue && (this.label = this.locations.map(function(e) {
            return e.getLabel()
        }).join(", ")),
        this.label && this.isValid() && (this.$el = E.select(document.createElement("li")).append(E.select(document.createElement("span")).text(this.label)).attr("data-constraint-id", this.id),
        this.deletable && this.$el.append(E.select(document.createElement("span")).addClass(t.classes.removeConstraint)))
    };
    E.extend(re.prototype, {
        isValid: function() {
            return this.locations.length > 0
        },
        getFields: function() {
            return this.locations.map(function(e) {
                return e.getFields()
            })
        }
    });
    var ue = {
        createConstraints: function() {
            var e = this;
            e.constraints = {},
            e.$constraints = E.select('<ul class="suggestions-constraints"/>'),
            e.$wrapper.append(e.$constraints),
            e.$constraints.on("click", "." + e.classes.removeConstraint, E.proxy(e.onConstraintRemoveClick, e))
        },
        setConstraintsPosition: function(e, t) {
            var n = this;
            n.$constraints.css({
                left: e.left + t.borderLeft + t.paddingLeft + "px",
                top: e.top + t.borderTop + Math.round((t.innerHeight - n.$constraints.height()) / 2) + "px"
            }),
            t.componentsLeft += n.$constraints.outerWidth(!0) + t.paddingLeft
        },
        onConstraintRemoveClick: function(e) {
            var t = this
              , n = E.select(e.target).closest("li")
              , i = n.attr("data-constraint-id");
            delete t.constraints[i],
            t.update(),
            n.fadeOut("fast", function() {
                t.removeConstraint(i)
            })
        },
        setupConstraints: function() {
            var e, t = this, n = t.options.constraints;
            if (!n)
                return void t.unbindFromParent();
            E.isJqObject(n) || "string" == typeof n || "number" == typeof n.nodeType ? (e = E.select(n),
            e.is(t.constraints) || (t.unbindFromParent(),
            e.is(t.el) || (t.constraints = e,
            t.bindToParent()))) : (t._constraintsUpdating = !0,
            h.each(t.constraints, function(e, n) {
                t.removeConstraint(n)
            }),
            h.each(h.makeArray(n), function(e, n) {
                t.addConstraint(e)
            }),
            t._constraintsUpdating = !1,
            t.fixPosition())
        },
        filteredLocation: function(e) {
            var t = []
              , n = {};
            if (h.each(this.type.dataComponents, function() {
                this.forLocations && t.push(this.id)
            }),
            g.isPlainObject(e) && h.each(e, function(e, i) {
                e && t.indexOf(i) >= 0 && (n[i] = e)
            }),
            !g.isEmptyObject(n))
                return n.kladr_id ? {
                    kladr_id: n.kladr_id
                } : n
        },
        addConstraint: function(e) {
            var t = this;
            e = new re(e,t),
            e.isValid() && (t.constraints[e.id] = e,
            e.$el && (t.$constraints.append(e.$el),
            t._constraintsUpdating || t.fixPosition()))
        },
        removeConstraint: function(e) {
            var t = this;
            delete t.constraints[e],
            t.$constraints.children('[data-constraint-id="' + e + '"]').remove(),
            t._constraintsUpdating || t.fixPosition()
        },
        constructConstraintsParams: function() {
            for (var e, t, n = this, i = [], s = n.constraints, o = {}; E.isJqObject(s) && (e = s.suggestions()) && !(t = y.getDeepValue(e, "selection.data")); )
                s = e.constraints;
            return E.isJqObject(s) ? (t = new ae(t,e).getFields()) && (n.bounds.own.indexOf("city") > -1 && delete t.city_fias_id,
            o.locations = [t],
            o.restrict_value = !0) : s && (h.each(s, function(e, t) {
                i = i.concat(e.getFields())
            }),
            i.length && (o.locations = i,
            o.restrict_value = n.options.restrict_value)),
            o
        },
        getFirstConstraintLabel: function() {
            var e = this
              , t = g.isPlainObject(e.constraints) && Object.keys(e.constraints)[0];
            return t ? e.constraints[t].label : ""
        },
        bindToParent: function() {
            var e = this;
            e.constraints.on(["suggestions-select." + e.uniqueId, "suggestions-invalidateselection." + e.uniqueId, "suggestions-clear." + e.uniqueId].join(" "), E.proxy(e.onParentSelectionChanged, e)).on("suggestions-dispose." + e.uniqueId, E.proxy(e.onParentDispose, e))
        },
        unbindFromParent: function() {
            var e = this
              , t = e.constraints;
            E.isJqObject(t) && t.off("." + e.uniqueId)
        },
        onParentSelectionChanged: function(e, t, n) {
            ("suggestions-select" !== e.type || n) && this.clear()
        },
        onParentDispose: function(e) {
            this.unbindFromParent()
        },
        getParentInstance: function() {
            return E.isJqObject(this.constraints) && this.constraints.suggestions()
        },
        shareWithParent: function(e) {
            var t = this.getParentInstance();
            t && t.type === this.type && !f(e, t) && (t.shareWithParent(e),
            t.setSuggestion(e))
        },
        getUnrestrictedData: function(e) {
            var t = this
              , n = []
              , i = {}
              , s = -1;
            return h.each(t.constraints, function(t, n) {
                h.each(t.locations, function(t, n) {
                    t.containsData(e) && t.specificity > s && (s = t.specificity)
                })
            }),
            s >= 0 ? (e.region_kladr_id && e.region_kladr_id === e.city_kladr_id && n.push.apply(n, t.type.dataComponentsById.city.fields),
            h.each(t.type.dataComponents.slice(0, s + 1), function(e, t) {
                n.push.apply(n, e.fields)
            }),
            h.each(e, function(e, t) {
                -1 === n.indexOf(t) && (i[t] = e)
            })) : i = e,
            i
        }
    };
    E.extend(j, se),
    E.extend(a.prototype, ue),
    "GET" != k.getDefaultType() && M.on("initialize", ue.createConstraints).on("setOptions", ue.setupConstraints).on("fixPosition", ue.setConstraintsPosition).on("requestParams", ue.constructConstraintsParams).on("dispose", ue.unbindFromParent);
    var le = {
        proceedQuery: function(e) {
            var t = this;
            e.length >= t.options.minChars ? t.updateSuggestions(e) : t.hide()
        },
        selectCurrentValue: function(e) {
            var t = this
              , n = E.Deferred();
            return t.inputPhase.resolve(),
            t.fetchPhase.done(function() {
                var i;
                t.selection && !t.visible ? n.reject() : (i = t.findSuggestionIndex(),
                t.select(i, e),
                -1 === i ? n.reject() : n.resolve(i))
            }).fail(function() {
                n.reject()
            }),
            n
        },
        selectFoundSuggestion: function() {
            var e = this;
            e.requestMode.userSelect || e.select(0)
        },
        findSuggestionIndex: function() {
            var e, t = this, n = t.selectedIndex;
            return -1 === n && (e = t.el.val().trim()) && t.type.matchers.some(function(i) {
                return -1 !== (n = i(e, t.suggestions))
            }),
            n
        },
        select: function(e, t) {
            var n, i = this, s = i.suggestions[e], o = t && t.continueSelecting, a = i.currentValue;
            if (!i.triggering.Select) {
                if (!s)
                    return o || i.selection || i.triggerOnSelectNothing(),
                    void i.onSelectComplete(o);
                n = i.hasSameValues(s),
                i.enrichSuggestion(s, t).done(function(s, o) {
                    var r = E.extend({
                        hasBeenEnriched: o,
                        hasSameValues: n
                    }, t);
                    i.selectSuggestion(s, e, a, r)
                })
            }
        },
        selectSuggestion: function(e, t, n, i) {
            var s = this
              , o = i.continueSelecting
              , a = !s.type.isDataComplete || s.type.isDataComplete.call(s, e)
              , r = s.selection;
            s.triggering.Select || (s.type.alwaysContinueSelecting && (o = !0),
            a && (o = !1),
            i.hasBeenEnriched && s.suggestions[t] && (s.suggestions[t].data = e.data),
            s.requestMode.updateValue && (s.checkValueBounds(e),
            s.currentValue = s.getSuggestionValue(e, i),
            !s.currentValue || i.noSpace || a || (s.currentValue += " "),
            s.el.val(s.currentValue)),
            s.currentValue ? (s.selection = e,
            s.areSuggestionsSame(e, r) || s.trigger("Select", e, s.currentValue != n),
            s.requestMode.userSelect && s.onSelectComplete(o)) : (s.selection = null,
            s.triggerOnSelectNothing()),
            s.shareWithParent(e))
        },
        onSelectComplete: function(e) {
            var t = this;
            e ? (t.selectedIndex = -1,
            t.updateSuggestions(t.currentValue)) : t.hide()
        },
        triggerOnSelectNothing: function() {
            var e = this;
            e.triggering.SelectNothing || e.trigger("SelectNothing", e.currentValue)
        },
        trigger: function(e) {
            var t = this
              , n = T.slice(arguments, 1)
              , i = t.options["on" + e];
            t.triggering[e] = !0,
            T.isFunction(i) && i.apply(t.element, n),
            t.el.trigger.call(t.el, "suggestions-" + e.toLowerCase(), n),
            t.triggering[e] = !1
        }
    };
    E.extend(a.prototype, le),
    M.on("assignSuggestions", le.selectFoundSuggestion);
    var ce = {
        bounds: null
    }
      , de = {
        setupBounds: function() {
            this.bounds = {
                from: null,
                to: null
            }
        },
        setBoundsOptions: function() {
            var t, n, i = this, s = [], o = e.trim(i.options.bounds).split("-"), a = o[0], r = o[o.length - 1], u = [], l = [];
            i.type.dataComponents && e.each(i.type.dataComponents, function() {
                this.forBounds && s.push(this.id)
            }),
            -1 === e.inArray(a, s) && (a = null),
            n = e.inArray(r, s),
            -1 !== n && n !== s.length - 1 || (r = null),
            (a || r) && (t = !a,
            e.each(s, function(e, n) {
                if (n == a && (t = !0),
                l.push(n),
                t && u.push(n),
                n == r)
                    return !1
            })),
            i.bounds.from = a,
            i.bounds.to = r,
            i.bounds.all = l,
            i.bounds.own = u
        },
        constructBoundsParams: function() {
            var e = this
              , t = {};
            return e.bounds.from && (t.from_bound = {
                value: e.bounds.from
            }),
            e.bounds.to && (t.to_bound = {
                value: e.bounds.to
            }),
            t
        },
        checkValueBounds: function(e) {
            var t, n = this;
            if (n.bounds.own.length && n.type.composeValue) {
                var i = n.bounds.own.slice(0);
                1 === i.length && "city_district" === i[0] && i.push("city_district_fias_id"),
                t = n.copyDataComponents(e.data, i),
                e.value = n.type.composeValue(t)
            }
        },
        copyDataComponents: function(t, n) {
            var i = {}
              , s = this.type.dataComponentsById;
            return s && e.each(n, function(n, o) {
                e.each(s[o].fields, function(e, n) {
                    null != t[n] && (i[n] = t[n])
                })
            }),
            i
        },
        getBoundedKladrId: function(t, n) {
            var i, s = n[n.length - 1];
            return e.each(this.type.dataComponents, function(e, t) {
                if (t.id === s)
                    return i = t.kladrFormat,
                    !1
            }),
            t.substr(0, i.digits) + new Array((i.zeros || 0) + 1).join("0")
        }
    };
    e.extend(j, ce),
    e.extend(a.prototype, de),
    M.on("initialize", de.setupBounds).on("setOptions", de.setBoundsOptions).on("requestParams", de.constructBoundsParams),
    a.defaultOptions = j,
    a.version = "18.3.3",
    e.Suggestions = a,
    e.fn.suggestions = function(t, n) {
        return 0 === arguments.length ? this.first().data("suggestions") : this.each(function() {
            var i = e(this)
              , s = i.data("suggestions");
            "string" == typeof t ? s && "function" == typeof s[t] && s[t](n) : (s && s.dispose && s.dispose(),
            s = new a(this,t),
            i.data("suggestions", s))
        })
    }
});
