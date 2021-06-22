!function (e, t) {
  'use strict';
  'object' == typeof module && 'object' == typeof module.exports ? module.exports = e.document ? t(e, !0)  : function (e) {
    if (!e.document) throw new Error('jQuery requires a window with a document');
    return t(e)
  }
   : t(e)
}('undefined' != typeof window ? window : this, function (e, t) {
  'use strict';
  function n(e, t, n) {
    var r,
    o = (t = t || ae).createElement('script');
    if (o.text = e, n) for (r in be) n[r] && (o[r] = n[r]);
    t.head.appendChild(o).parentNode.removeChild(o)
  }
  function r(e) {
    return null == e ? e + '' : 'object' == typeof e || 'function' == typeof e ? fe[pe.call(e)] || 'object' : typeof e
  }
  function o(e) {
    var t = !!e && 'length' in e && e.length,
    n = r(e);
    return !ye(e) && !xe(e) && ('array' === n || 0 === t || 'number' == typeof t && t > 0 && t - 1 in e)
  }
  function i(e, t) {
    return e.nodeName && e.nodeName.toLowerCase() === t.toLowerCase()
  }
  function a(e, t, n) {
    return ye(t) ? we.grep(e, function (e, r) {
      return !!t.call(e, r, e) !== n
    })  : t.nodeType ? we.grep(e, function (e) {
      return e === t !== n
    })  : 'string' != typeof t ? we.grep(e, function (e) {
      return de.call(t, e) > - 1 !== n
    })  : we.filter(t, e, n)
  }
  function s(e, t) {
    for (; (e = e[t]) && 1 !== e.nodeType; );
    return e
  }
  function l(e) {
    var t = {
    };
    return we.each(e.match(Be) || [
    ], function (e, n) {
      t[n] = !0
    }),
    t
  }
  function c(e) {
    return e
  }
  function u(e) {
    throw e
  }
  function d(e, t, n, r) {
    var o;
    try {
      e && ye(o = e.promise) ? o.call(e).done(t).fail(n)  : e && ye(o = e.then) ? o.call(e, t, n)  : t.apply(void 0, [
        e
      ].slice(r))
    } catch (e) {
      n.apply(void 0, [
        e
      ])
    }
  }
  function f() {
    ae.removeEventListener('DOMContentLoaded', f),
    e.removeEventListener('load', f),
    we.ready()
  }
  function p(e, t) {
    return t.toUpperCase()
  }
  function h(e) {
    return e.replace(Ie, 'ms-').replace(Pe, p)
  }
  function m() {
    this.expando = we.expando + m.uid++
  }
  function g(e) {
    return 'true' === e || 'false' !== e && ('null' === e ? null : e === + e + '' ? + e : We.test(e) ? JSON.parse(e)  : e)
  }
  function v(e, t, n) {
    var r;
    if (void 0 === n && 1 === e.nodeType) if (r = 'data-' + t.replace(ze, '-$&').toLowerCase(), 'string' == typeof (n = e.getAttribute(r))) {
      try {
        n = g(n)
      } catch (e) {
      }
      Re.set(e, t, n)
    } else n = void 0;
    return n
  }
  function y(e, t, n, r) {
    var o,
    i,
    a = 20,
    s = r ? function () {
      return r.cur()
    }
     : function () {
      return we.css(e, t, '')
    },
    l = s(),
    c = n && n[3] || (we.cssNumber[t] ? '' : 'px'),
    u = (we.cssNumber[t] || 'px' !== c && + l) && $e.exec(we.css(e, t));
    if (u && u[3] !== c) {
      for (l /= 2, c = c || u[3], u = + l || 1; a--; ) we.style(e, t, u + c),
      (1 - i) * (1 - (i = s() / l || 0.5)) <= 0 && (a = 0),
      u /= i;
      u *= 2,
      we.style(e, t, u + c),
      n = n || [
      ]
    }
    return n && (u = + u || + l || 0, o = n[1] ? u + (n[1] + 1) * n[2] : + n[2], r && (r.unit = c, r.start = u, r.end = o)),
    o
  }
  function x(e) {
    var t,
    n = e.ownerDocument,
    r = e.nodeName,
    o = Ve[r];
    return o || (t = n.body.appendChild(n.createElement(r)), o = we.css(t, 'display'), t.parentNode.removeChild(t), 'none' === o && (o = 'block'), Ve[r] = o, o)
  }
  function b(e, t) {
    for (var n, r, o = [
    ], i = 0, a = e.length; i < a; i++) (r = e[i]).style && (n = r.style.display, t ? ('none' === n && (o[i] = qe.get(r, 'display') || null, o[i] || (r.style.display = '')), '' === r.style.display && Ue(r) && (o[i] = x(r)))  : 'none' !== n && (o[i] = 'none', qe.set(r, 'display', n)));
    for (i = 0; i < a; i++) null != o[i] && (e[i].style.display = o[i]);
    return e
  }
  function w(e, t) {
    var n;
    return n = void 0 !== e.getElementsByTagName ? e.getElementsByTagName(t || '*')  : void 0 !== e.querySelectorAll ? e.querySelectorAll(t || '*')  : [
    ],
    void 0 === t || t && i(e, t) ? we.merge([e], n)  : n
  }
  function S(e, t) {
    for (var n = 0, r = e.length; n < r; n++) qe.set(e[n], 'globalEval', !t || qe.get(t[n], 'globalEval'))
  }
  function C(e, t, n, o, i) {
    for (var a, s, l, c, u, d, f = t.createDocumentFragment(), p = [
    ], h = 0, m = e.length; h < m; h++) if ((a = e[h]) || 0 === a) if ('object' === r(a)) we.merge(p, a.nodeType ? [
      a
    ] : a);
     else if (Ze.test(a)) {
      for (s = s || f.appendChild(t.createElement('div')), l = (Qe.exec(a) || [
        '',
        ''
      ]) [1].toLowerCase(), c = Je[l] || Je._default, s.innerHTML = c[1] + we.htmlPrefilter(a) + c[2], d = c[0]; d--; ) s = s.lastChild;
      we.merge(p, s.childNodes),
      (s = f.firstChild).textContent = ''
    } else p.push(t.createTextNode(a));
    for (f.textContent = '', h = 0; a = p[h++]; ) if (o && we.inArray(a, o) > - 1) i && i.push(a);
     else if (u = we.contains(a.ownerDocument, a), s = w(f.appendChild(a), 'script'), u && S(s), n) for (d = 0; a = s[d++]; ) Ke.test(a.type || '') && n.push(a);
    return f
  }
  function T() {
    return !0
  }
  function k() {
    return !1
  }
  function _() {
    try {
      return ae.activeElement
    } catch (e) {
    }
  }
  function D(e, t, n, r, o, i) {
    var a,
    s;
    if ('object' == typeof t) {
      'string' != typeof n && (r = r || n, n = void 0);
      for (s in t) D(e, s, n, r, t[s], i);
      return e
    }
    if (null == r && null == o ? (o = n, r = n = void 0)  : null == o && ('string' == typeof n ? (o = r, r = void 0)  : (o = r, r = n, n = void 0)), !1 === o) o = k;
     else if (!o) return e;
    return 1 === i && (a = o, (o = function (e) {
      return we().off(e),
      a.apply(this, arguments)
    }).guid = a.guid || (a.guid = we.guid++)),
    e.each(function () {
      we.event.add(this, t, o, r, n)
    })
  }
  function E(e, t) {
    return i(e, 'table') && i(11 !== t.nodeType ? t : t.firstChild, 'tr') ? we(e).children('tbody') [0] || e : e
  }
  function M(e) {
    return e.type = (null !== e.getAttribute('type')) + '/' + e.type,
    e
  }
  function A(e) {
    return 'true/' === (e.type || '').slice(0, 5) ? e.type = e.type.slice(5)  : e.removeAttribute('type'),
    e
  }
  function j(e, t) {
    var n,
    r,
    o,
    i,
    a,
    s,
    l,
    c;
    if (1 === t.nodeType) {
      if (qe.hasData(e) && (i = qe.access(e), a = qe.set(t, i), c = i.events)) {
        delete a.handle,
        a.events = {
        };
        for (o in c) for (n = 0, r = c[o].length; n < r; n++) we.event.add(t, o, c[o][n])
      }
      Re.hasData(e) && (s = Re.access(e), l = we.extend({
      }, s), Re.set(t, l))
    }
  }
  function B(e, t) {
    var n = t.nodeName.toLowerCase();
    'input' === n && Ge.test(e.type) ? t.checked = e.checked : 'input' !== n && 'textarea' !== n || (t.defaultValue = e.defaultValue)
  }
  function O(e, t, r, o) {
    t = ce.apply([], t);
    var i,
    a,
    s,
    l,
    c,
    u,
    d = 0,
    f = e.length,
    p = f - 1,
    h = t[0],
    m = ye(h);
    if (m || f > 1 && 'string' == typeof h && !ve.checkClone && at.test(h)) return e.each(function (n) {
      var i = e.eq(n);
      m && (t[0] = h.call(this, n, i.html())),
      O(i, t, r, o)
    });
    if (f && (i = C(t, e[0].ownerDocument, !1, e, o), a = i.firstChild, 1 === i.childNodes.length && (i = a), a || o)) {
      for (l = (s = we.map(w(i, 'script'), M)).length; d < f; d++) c = i,
      d !== p && (c = we.clone(c, !0, !0), l && we.merge(s, w(c, 'script'))),
      r.call(e[d], c, d);
      if (l) for (u = s[s.length - 1].ownerDocument, we.map(s, A), d = 0; d < l; d++) c = s[d],
      Ke.test(c.type || '') && !qe.access(c, 'globalEval') && we.contains(u, c) && (c.src && 'module' !== (c.type || '').toLowerCase() ? we._evalUrl && we._evalUrl(c.src)  : n(c.textContent.replace(st, ''), u, c))
    }
    return e
  }
  function L(e, t, n) {
    for (var r, o = t ? we.filter(t, e)  : e, i = 0; null != (r = o[i]); i++) n || 1 !== r.nodeType || we.cleanData(w(r)),
    r.parentNode && (n && we.contains(r.ownerDocument, r) && S(w(r, 'script')), r.parentNode.removeChild(r));
    return e
  }
  function N(e, t, n) {
    var r,
    o,
    i,
    a,
    s = e.style;
    return (n = n || ct(e)) && ('' !== (a = n.getPropertyValue(t) || n[t]) || we.contains(e.ownerDocument, e) || (a = we.style(e, t)), !ve.pixelBoxStyles() && lt.test(a) && ut.test(t) && (r = s.width, o = s.minWidth, i = s.maxWidth, s.minWidth = s.maxWidth = s.width = a, a = n.width, s.width = r, s.minWidth = o, s.maxWidth = i)),
    void 0 !== a ? a + '' : a
  }
  function I(e, t) {
    return {
      get: function () {
        if (!e()) return (this.get = t).apply(this, arguments);
        delete this.get
      }
    }
  }
  function P(e) {
    if (e in gt) return e;
    for (var t = e[0].toUpperCase() + e.slice(1), n = mt.length; n--; ) if ((e = mt[n] + t) in gt) return e
  }
  function H(e) {
    var t = we.cssProps[e];
    return t || (t = we.cssProps[e] = P(e) || e),
    t
  }
  function q(e, t, n) {
    var r = $e.exec(t);
    return r ? Math.max(0, r[2] - (n || 0)) + (r[3] || 'px')  : t
  }
  function R(e, t, n, r, o, i) {
    var a = 'width' === t ? 1 : 0,
    s = 0,
    l = 0;
    if (n === (r ? 'border' : 'content')) return 0;
    for (; a < 4; a += 2) 'margin' === n && (l += we.css(e, n + Xe[a], !0, o)),
    r ? ('content' === n && (l -= we.css(e, 'padding' + Xe[a], !0, o)), 'margin' !== n && (l -= we.css(e, 'border' + Xe[a] + 'Width', !0, o)))  : (l += we.css(e, 'padding' + Xe[a], !0, o), 'padding' !== n ? l += we.css(e, 'border' + Xe[a] + 'Width', !0, o)  : s += we.css(e, 'border' + Xe[a] + 'Width', !0, o));
    return !r && i >= 0 && (l += Math.max(0, Math.ceil(e['offset' + t[0].toUpperCase() + t.slice(1)] - i - l - s - 0.5))),
    l
  }
  function W(e, t, n) {
    var r = ct(e),
    o = N(e, t, r),
    i = 'border-box' === we.css(e, 'boxSizing', !1, r),
    a = i;
    if (lt.test(o)) {
      if (!n) return o;
      o = 'auto'
    }
    return a = a && (ve.boxSizingReliable() || o === e.style[t]),
    ('auto' === o || !parseFloat(o) && 'inline' === we.css(e, 'display', !1, r)) && (o = e['offset' + t[0].toUpperCase() + t.slice(1)], a = !0),
    (o = parseFloat(o) || 0) + R(e, t, n || (i ? 'border' : 'content'), a, r, o) + 'px'
  }
  function z(e, t, n, r, o) {
    return new z.prototype.init(e, t, n, r, o)
  }
  function F() {
    yt && (!1 === ae.hidden && e.requestAnimationFrame ? e.requestAnimationFrame(F)  : e.setTimeout(F, we.fx.interval), we.fx.tick())
  }
  function $() {
    return e.setTimeout(function () {
      vt = void 0
    }),
    vt = Date.now()
  }
  function X(e, t) {
    var n,
    r = 0,
    o = {
      height: e
    };
    for (t = t ? 1 : 0; r < 4; r += 2 - t) o['margin' + (n = Xe[r])] = o['padding' + n] = e;
    return t && (o.opacity = o.width = e),
    o
  }
  function U(e, t, n) {
    for (var r, o = (G.tweeners[t] || [
    ]).concat(G.tweeners['*']), i = 0, a = o.length; i < a; i++) if (r = o[i].call(n, t, e)) return r
  }
  function Y(e, t, n) {
    var r,
    o,
    i,
    a,
    s,
    l,
    c,
    u,
    d = 'width' in t || 'height' in t,
    f = this,
    p = {
    },
    h = e.style,
    m = e.nodeType && Ue(e),
    g = qe.get(e, 'fxshow');
    n.queue || (null == (a = we._queueHooks(e, 'fx')).unqueued && (a.unqueued = 0, s = a.empty.fire, a.empty.fire = function () {
      a.unqueued || s()
    }), a.unqueued++, f.always(function () {
      f.always(function () {
        a.unqueued--,
        we.queue(e, 'fx').length || a.empty.fire()
      })
    }));
    for (r in t) if (o = t[r], xt.test(o)) {
      if (delete t[r], i = i || 'toggle' === o, o === (m ? 'hide' : 'show')) {
        if ('show' !== o || !g || void 0 === g[r]) continue;
        m = !0
      }
      p[r] = g && g[r] || we.style(e, r)
    }
    if ((l = !we.isEmptyObject(t)) || !we.isEmptyObject(p)) {
      d && 1 === e.nodeType && (n.overflow = [
        h.overflow,
        h.overflowX,
        h.overflowY
      ], null == (c = g && g.display) && (c = qe.get(e, 'display')), 'none' === (u = we.css(e, 'display')) && (c ? u = c : (b([e], !0), c = e.style.display || c, u = we.css(e, 'display'), b([e]))), ('inline' === u || 'inline-block' === u && null != c) && 'none' === we.css(e, 'float') && (l || (f.done(function () {
        h.display = c
      }), null == c && (u = h.display, c = 'none' === u ? '' : u)), h.display = 'inline-block')),
      n.overflow && (h.overflow = 'hidden', f.always(function () {
        h.overflow = n.overflow[0],
        h.overflowX = n.overflow[1],
        h.overflowY = n.overflow[2]
      })),
      l = !1;
      for (r in p) l || (g ? 'hidden' in g && (m = g.hidden)  : g = qe.access(e, 'fxshow', {
        display: c
      }), i && (g.hidden = !m), m && b([e], !0), f.done(function () {
        m || b([e]),
        qe.remove(e, 'fxshow');
        for (r in p) we.style(e, r, p[r])
      })),
      l = U(m ? g[r] : 0, r, f),
      r in g || (g[r] = l.start, m && (l.end = l.start, l.start = 0))
    }
  }
  function V(e, t) {
    var n,
    r,
    o,
    i,
    a;
    for (n in e) if (r = h(n), o = t[r], i = e[n], Array.isArray(i) && (o = i[1], i = e[n] = i[0]), n !== r && (e[r] = i, delete e[n]), (a = we.cssHooks[r]) && 'expand' in a) {
      i = a.expand(i),
      delete e[r];
      for (n in i) n in e || (e[n] = i[n], t[n] = o)
    } else t[r] = o
  }
  function G(e, t, n) {
    var r,
    o,
    i = 0,
    a = G.prefilters.length,
    s = we.Deferred().always(function () {
      delete l.elem
    }),
    l = function () {
      if (o) return !1;
      for (var t = vt || $(), n = Math.max(0, c.startTime + c.duration - t), r = 1 - (n / c.duration || 0), i = 0, a = c.tweens.length; i < a; i++) c.tweens[i].run(r);
      return s.notifyWith(e, [
        c,
        r,
        n
      ]),
      r < 1 && a ? n : (a || s.notifyWith(e, [
        c,
        1,
        0
      ]), s.resolveWith(e, [
        c
      ]), !1)
    },
    c = s.promise({
      elem: e,
      props: we.extend({
      }, t),
      opts: we.extend(!0, {
        specialEasing: {
        },
        easing: we.easing._default
      }, n),
      originalProperties: t,
      originalOptions: n,
      startTime: vt || $(),
      duration: n.duration,
      tweens: [
      ],
      createTween: function (t, n) {
        var r = we.Tween(e, c.opts, t, n, c.opts.specialEasing[t] || c.opts.easing);
        return c.tweens.push(r),
        r
      },
      stop: function (t) {
        var n = 0,
        r = t ? c.tweens.length : 0;
        if (o) return this;
        for (o = !0; n < r; n++) c.tweens[n].run(1);
        return t ? (s.notifyWith(e, [
          c,
          1,
          0
        ]), s.resolveWith(e, [
          c,
          t
        ]))  : s.rejectWith(e, [
          c,
          t
        ]),
        this
      }
    }),
    u = c.props;
    for (V(u, c.opts.specialEasing); i < a; i++) if (r = G.prefilters[i].call(c, e, u, c.opts)) return ye(r.stop) && (we._queueHooks(c.elem, c.opts.queue).stop = r.stop.bind(r)),
    r;
    return we.map(u, U, c),
    ye(c.opts.start) && c.opts.start.call(e, c),
    c.progress(c.opts.progress).done(c.opts.done, c.opts.complete).fail(c.opts.fail).always(c.opts.always),
    we.fx.timer(we.extend(l, {
      elem: e,
      anim: c,
      queue: c.opts.queue
    })),
    c
  }
  function Q(e) {
    return (e.match(Be) || [
    ]).join(' ')
  }
  function K(e) {
    return e.getAttribute && e.getAttribute('class') || ''
  }
  function J(e) {
    return Array.isArray(e) ? e : 'string' == typeof e ? e.match(Be) || [
    ] : [
    ]
  }
  function Z(e, t, n, o) {
    var i;
    if (Array.isArray(t)) we.each(t, function (t, r) {
      n || jt.test(e) ? o(e, r)  : Z(e + '[' + ('object' == typeof r && null != r ? t : '') + ']', r, n, o)
    });
     else if (n || 'object' !== r(t)) o(e, t);
     else for (i in t) Z(e + '[' + i + ']', t[i], n, o)
  }
  function ee(e) {
    return function (t, n) {
      'string' != typeof t && (n = t, t = '*');
      var r,
      o = 0,
      i = t.toLowerCase().match(Be) || [
      ];
      if (ye(n)) for (; r = i[o++]; ) '+' === r[0] ? (r = r.slice(1) || '*', (e[r] = e[r] || [
      ]).unshift(n))  : (e[r] = e[r] || [
      ]).push(n)
    }
  }
  function te(e, t, n, r) {
    function o(s) {
      var l;
      return i[s] = !0,
      we.each(e[s] || [
      ], function (e, s) {
        var c = s(t, n, r);
        return 'string' != typeof c || a || i[c] ? a ? !(l = c)  : void 0 : (t.dataTypes.unshift(c), o(c), !1)
      }),
      l
    }
    var i = {
    },
    a = e === Ft;
    return o(t.dataTypes[0]) || !i['*'] && o('*')
  }
  function ne(e, t) {
    var n,
    r,
    o = we.ajaxSettings.flatOptions || {
    };
    for (n in t) void 0 !== t[n] && ((o[n] ? e : r || (r = {
    })) [n] = t[n]);
    return r && we.extend(!0, e, r),
    e
  }
  function re(e, t, n) {
    for (var r, o, i, a, s = e.contents, l = e.dataTypes; '*' === l[0]; ) l.shift(),
    void 0 === r && (r = e.mimeType || t.getResponseHeader('Content-Type'));
    if (r) for (o in s) if (s[o] && s[o].test(r)) {
      l.unshift(o);
      break
    }
    if (l[0] in n) i = l[0];
     else {
      for (o in n) {
        if (!l[0] || e.converters[o + ' ' + l[0]]) {
          i = o;
          break
        }
        a || (a = o)
      }
      i = i || a
    }
    if (i) return i !== l[0] && l.unshift(i),
    n[i]
  }
  function oe(e, t, n, r) {
    var o,
    i,
    a,
    s,
    l,
    c = {
    },
    u = e.dataTypes.slice();
    if (u[1]) for (a in e.converters) c[a.toLowerCase()] = e.converters[a];
    for (i = u.shift(); i; ) if (e.responseFields[i] && (n[e.responseFields[i]] = t), !l && r && e.dataFilter && (t = e.dataFilter(t, e.dataType)), l = i, i = u.shift()) if ('*' === i) i = l;
     else if ('*' !== l && l !== i) {
      if (!(a = c[l + ' ' + i] || c['* ' + i])) for (o in c) if ((s = o.split(' ')) [1] === i && (a = c[l + ' ' + s[0]] || c['* ' + s[0]])) {
        !0 === a ? a = c[o] : !0 !== c[o] && (i = s[0], u.unshift(s[1]));
        break
      }
      if (!0 !== a) if (a && e.throws) t = a(t);
       else try {
        t = a(t)
      } catch (e) {
        return {
          state: 'parsererror',
          error: a ? e : 'No conversion from ' + l + ' to ' + i
        }
      }
    }
    return {
      state: 'success',
      data: t
    }
  }
  var ie = [
  ],
  ae = e.document,
  se = Object.getPrototypeOf,
  le = ie.slice,
  ce = ie.concat,
  ue = ie.push,
  de = ie.indexOf,
  fe = {
  },
  pe = fe.toString,
  he = fe.hasOwnProperty,
  me = he.toString,
  ge = me.call(Object),
  ve = {
  },
  ye = function (e) {
    return 'function' == typeof e && 'number' != typeof e.nodeType
  },
  xe = function (e) {
    return null != e && e === e.window
  },
  be = {
    type: !0,
    src: !0,
    noModule: !0
  },
  we = function (e, t) {
    return new we.fn.init(e, t)
  },
  Se = /^[\s\uFEFF\xA0]+|[\s\uFEFF\xA0]+$/g;
  we.fn = we.prototype = {
    jquery: '3.3.1',
    constructor: we,
    length: 0,
    toArray: function () {
      return le.call(this)
    },
    get: function (e) {
      return null == e ? le.call(this)  : e < 0 ? this[e + this.length] : this[e]
    },
    pushStack: function (e) {
      var t = we.merge(this.constructor(), e);
      return t.prevObject = this,
      t
    },
    each: function (e) {
      return we.each(this, e)
    },
    map: function (e) {
      return this.pushStack(we.map(this, function (t, n) {
        return e.call(t, n, t)
      }))
    },
    slice: function () {
      return this.pushStack(le.apply(this, arguments))
    },
    first: function () {
      return this.eq(0)
    },
    last: function () {
      return this.eq( - 1)
    },
    eq: function (e) {
      var t = this.length,
      n = + e + (e < 0 ? t : 0);
      return this.pushStack(n >= 0 && n < t ? [
        this[n]
      ] : [
      ])
    },
    end: function () {
      return this.prevObject || this.constructor()
    },
    push: ue,
    sort: ie.sort,
    splice: ie.splice
  },
  we.extend = we.fn.extend = function () {
    var e,
    t,
    n,
    r,
    o,
    i,
    a = arguments[0] || {
    },
    s = 1,
    l = arguments.length,
    c = !1;
    for ('boolean' == typeof a && (c = a, a = arguments[s] || {
    }, s++), 'object' == typeof a || ye(a) || (a = {
    }), s === l && (a = this, s--); s < l; s++) if (null != (e = arguments[s])) for (t in e) n = a[t],
    a !== (r = e[t]) && (c && r && (we.isPlainObject(r) || (o = Array.isArray(r))) ? (o ? (o = !1, i = n && Array.isArray(n) ? n : [
    ])  : i = n && we.isPlainObject(n) ? n : {
    }, a[t] = we.extend(c, i, r))  : void 0 !== r && (a[t] = r));
    return a
  },
  we.extend({
    expando: 'jQuery' + ('3.3.1' + Math.random()).replace(/\D/g, ''),
    isReady: !0,
    error: function (e) {
      throw new Error(e)
    },
    noop: function () {
    },
    isPlainObject: function (e) {
      var t,
      n;
      return !(!e || '[object Object]' !== pe.call(e) || (t = se(e)) && ('function' != typeof (n = he.call(t, 'constructor') && t.constructor) || me.call(n) !== ge))
    },
    isEmptyObject: function (e) {
      var t;
      for (t in e) return !1;
      return !0
    },
    globalEval: function (e) {
      n(e)
    },
    each: function (e, t) {
      var n,
      r = 0;
      if (o(e)) for (n = e.length; r < n && !1 !== t.call(e[r], r, e[r]); r++);
       else for (r in e) if (!1 === t.call(e[r], r, e[r])) break;
      return e
    },
    trim: function (e) {
      return null == e ? '' : (e + '').replace(Se, '')
    },
    makeArray: function (e, t) {
      var n = t || [
      ];
      return null != e && (o(Object(e)) ? we.merge(n, 'string' == typeof e ? [
        e
      ] : e)  : ue.call(n, e)),
      n
    },
    inArray: function (e, t, n) {
      return null == t ? - 1 : de.call(t, e, n)
    },
    merge: function (e, t) {
      for (var n = + t.length, r = 0, o = e.length; r < n; r++) e[o++] = t[r];
      return e.length = o,
      e
    },
    grep: function (e, t, n) {
      for (var r = [
      ], o = 0, i = e.length, a = !n; o < i; o++) !t(e[o], o) !== a && r.push(e[o]);
      return r
    },
    map: function (e, t, n) {
      var r,
      i,
      a = 0,
      s = [
      ];
      if (o(e)) for (r = e.length; a < r; a++) null != (i = t(e[a], a, n)) && s.push(i);
       else for (a in e) null != (i = t(e[a], a, n)) && s.push(i);
      return ce.apply([], s)
    },
    guid: 1,
    support: ve
  }),
  'function' == typeof Symbol && (we.fn[Symbol.iterator] = ie[Symbol.iterator]),
  we.each('Boolean Number String Function Array Date RegExp Object Error Symbol'.split(' '), function (e, t) {
    fe['[object ' + t + ']'] = t.toLowerCase()
  });
  var Ce = function (e) {
    function t(e, t, n, r) {
      var o,
      i,
      a,
      s,
      l,
      c,
      u,
      f = t && t.ownerDocument,
      h = t ? t.nodeType : 9;
      if (n = n || [
      ], 'string' != typeof e || !e || 1 !== h && 9 !== h && 11 !== h) return n;
      if (!r && ((t ? t.ownerDocument || t : W) !== O && B(t), t = t || O, N)) {
        if (11 !== h && (l = ve.exec(e))) if (o = l[1]) {
          if (9 === h) {
            if (!(a = t.getElementById(o))) return n;
            if (a.id === o) return n.push(a),
            n
          } else if (f && (a = f.getElementById(o)) && q(t, a) && a.id === o) return n.push(a),
          n
        } else {
          if (l[2]) return J.apply(n, t.getElementsByTagName(e)),
          n;
          if ((o = l[3]) && S.getElementsByClassName && t.getElementsByClassName) return J.apply(n, t.getElementsByClassName(o)),
          n
        }
        if (S.qsa && !U[e + ' '] && (!I || !I.test(e))) {
          if (1 !== h) f = t,
          u = e;
           else if ('object' !== t.nodeName.toLowerCase()) {
            for ((s = t.getAttribute('id')) ? s = s.replace(we, Se)  : t.setAttribute('id', s = R), i = (c = _(e)).length; i--; ) c[i] = '#' + s + ' ' + p(c[i]);
            u = c.join(','),
            f = ye.test(e) && d(t.parentNode) || t
          }
          if (u) try {
            return J.apply(n, f.querySelectorAll(u)),
            n
          } catch (e) {
          } finally {
            s === R && t.removeAttribute('id')
          }
        }
      }
      return E(e.replace(se, '$1'), t, n, r)
    }
    function n() {
      function e(n, r) {
        return t.push(n + ' ') > C.cacheLength && delete e[t.shift()],
        e[n + ' '] = r
      }
      var t = [
      ];
      return e
    }
    function r(e) {
      return e[R] = !0,
      e
    }
    function o(e) {
      var t = O.createElement('fieldset');
      try {
        return !!e(t)
      } catch (e) {
        return !1
      } finally {
        t.parentNode && t.parentNode.removeChild(t),
        t = null
      }
    }
    function i(e, t) {
      for (var n = e.split('|'), r = n.length; r--; ) C.attrHandle[n[r]] = t
    }
    function a(e, t) {
      var n = t && e,
      r = n && 1 === e.nodeType && 1 === t.nodeType && e.sourceIndex - t.sourceIndex;
      if (r) return r;
      if (n) for (; n = n.nextSibling; ) if (n === t) return - 1;
      return e ? 1 : - 1
    }
    function s(e) {
      return function (t) {
        return 'input' === t.nodeName.toLowerCase() && t.type === e
      }
    }
    function l(e) {
      return function (t) {
        var n = t.nodeName.toLowerCase();
        return ('input' === n || 'button' === n) && t.type === e
      }
    }
    function c(e) {
      return function (t) {
        return 'form' in t ? t.parentNode && !1 === t.disabled ? 'label' in t ? 'label' in t.parentNode ? t.parentNode.disabled === e : t.disabled === e : t.isDisabled === e || t.isDisabled !== !e && Te(t) === e : t.disabled === e : 'label' in t && t.disabled === e
      }
    }
    function u(e) {
      return r(function (t) {
        return t = + t,
        r(function (n, r) {
          for (var o, i = e([], n.length, t), a = i.length; a--; ) n[o = i[a]] && (n[o] = !(r[o] = n[o]))
        })
      })
    }
    function d(e) {
      return e && void 0 !== e.getElementsByTagName && e
    }
    function f() {
    }
    function p(e) {
      for (var t = 0, n = e.length, r = ''; t < n; t++) r += e[t].value;
      return r
    }
    function h(e, t, n) {
      var r = t.dir,
      o = t.next,
      i = o || r,
      a = n && 'parentNode' === i,
      s = F++;
      return t.first ? function (t, n, o) {
        for (; t = t[r]; ) if (1 === t.nodeType || a) return e(t, n, o);
        return !1
      }
       : function (t, n, l) {
        var c,
        u,
        d,
        f = [
          z,
          s
        ];
        if (l) {
          for (; t = t[r]; ) if ((1 === t.nodeType || a) && e(t, n, l)) return !0
        } else for (; t = t[r]; ) if (1 === t.nodeType || a) if (d = t[R] || (t[R] = {
        }), u = d[t.uniqueID] || (d[t.uniqueID] = {
        }), o && o === t.nodeName.toLowerCase()) t = t[r] || t;
         else {
          if ((c = u[i]) && c[0] === z && c[1] === s) return f[2] = c[2];
          if (u[i] = f, f[2] = e(t, n, l)) return !0
        }
        return !1
      }
    }
    function m(e) {
      return e.length > 1 ? function (t, n, r) {
        for (var o = e.length; o--; ) if (!e[o](t, n, r)) return !1;
        return !0
      }
       : e[0]
    }
    function g(e, n, r) {
      for (var o = 0, i = n.length; o < i; o++) t(e, n[o], r);
      return r
    }
    function v(e, t, n, r, o) {
      for (var i, a = [
      ], s = 0, l = e.length, c = null != t; s < l; s++) (i = e[s]) && (n && !n(i, r, o) || (a.push(i), c && t.push(s)));
      return a
    }
    function y(e, t, n, o, i, a) {
      return o && !o[R] && (o = y(o)),
      i && !i[R] && (i = y(i, a)),
      r(function (r, a, s, l) {
        var c,
        u,
        d,
        f = [
        ],
        p = [
        ],
        h = a.length,
        m = r || g(t || '*', s.nodeType ? [
          s
        ] : s, [
        ]),
        y = !e || !r && t ? m : v(m, f, e, s, l),
        x = n ? i || (r ? e : h || o) ? [
        ] : a : y;
        if (n && n(y, x, s, l), o) for (c = v(x, p), o(c, [
        ], s, l), u = c.length; u--; ) (d = c[u]) && (x[p[u]] = !(y[p[u]] = d));
        if (r) {
          if (i || e) {
            if (i) {
              for (c = [
              ], u = x.length; u--; ) (d = x[u]) && c.push(y[u] = d);
              i(null, x = [
              ], c, l)
            }
            for (u = x.length; u--; ) (d = x[u]) && (c = i ? ee(r, d)  : f[u]) > - 1 && (r[c] = !(a[c] = d))
          }
        } else x = v(x === a ? x.splice(h, x.length)  : x),
        i ? i(null, a, x, l)  : J.apply(a, x)
      })
    }
    function x(e) {
      for (var t, n, r, o = e.length, i = C.relative[e[0].type], a = i || C.relative[' '], s = i ? 1 : 0, l = h(function (e) {
        return e === t
      }, a, !0), c = h(function (e) {
        return ee(t, e) > - 1
      }, a, !0), u = [
        function (e, n, r) {
          var o = !i && (r || n !== M) || ((t = n).nodeType ? l(e, n, r)  : c(e, n, r));
          return t = null,
          o
        }
      ]; s < o; s++) if (n = C.relative[e[s].type]) u = [
        h(m(u), n)
      ];
       else {
        if ((n = C.filter[e[s].type].apply(null, e[s].matches)) [R]) {
          for (r = ++s; r < o && !C.relative[e[r].type]; r++);
          return y(s > 1 && m(u), s > 1 && p(e.slice(0, s - 1).concat({
            value: ' ' === e[s - 2].type ? '*' : ''
          })).replace(se, '$1'), n, s < r && x(e.slice(s, r)), r < o && x(e = e.slice(r)), r < o && p(e))
        }
        u.push(n)
      }
      return m(u)
    }
    function b(e, n) {
      var o = n.length > 0,
      i = e.length > 0,
      a = function (r, a, s, l, c) {
        var u,
        d,
        f,
        p = 0,
        h = '0',
        m = r && [
        ],
        g = [
        ],
        y = M,
        x = r || i && C.find.TAG('*', c),
        b = z += null == y ? 1 : Math.random() || 0.1,
        w = x.length;
        for (c && (M = a === O || a || c); h !== w && null != (u = x[h]); h++) {
          if (i && u) {
            for (d = 0, a || u.ownerDocument === O || (B(u), s = !N); f = e[d++]; ) if (f(u, a || O, s)) {
              l.push(u);
              break
            }
            c && (z = b)
          }
          o && ((u = !f && u) && p--, r && m.push(u))
        }
        if (p += h, o && h !== p) {
          for (d = 0; f = n[d++]; ) f(m, g, a, s);
          if (r) {
            if (p > 0) for (; h--; ) m[h] || g[h] || (g[h] = Q.call(l));
            g = v(g)
          }
          J.apply(l, g),
          c && !r && g.length > 0 && p + n.length > 1 && t.uniqueSort(l)
        }
        return c && (z = b, M = y),
        m
      };
      return o ? r(a)  : a
    }
    var w,
    S,
    C,
    T,
    k,
    _,
    D,
    E,
    M,
    A,
    j,
    B,
    O,
    L,
    N,
    I,
    P,
    H,
    q,
    R = 'sizzle' + 1 * new Date,
    W = e.document,
    z = 0,
    F = 0,
    $ = n(),
    X = n(),
    U = n(),
    Y = function (e, t) {
      return e === t && (j = !0),
      0
    },
    V = {
    }.hasOwnProperty,
    G = [
    ],
    Q = G.pop,
    K = G.push,
    J = G.push,
    Z = G.slice,
    ee = function (e, t) {
      for (var n = 0, r = e.length; n < r; n++) if (e[n] === t) return n;
      return - 1
    },
    te = 'checked|selected|async|autofocus|autoplay|controls|defer|disabled|hidden|ismap|loop|multiple|open|readonly|required|scoped',
    ne = '[\\x20\\t\\r\\n\\f]',
    re = '(?:\\\\.|[\\w-]|[^\0-\\xa0])+',
    oe = '\\[' + ne + '*(' + re + ')(?:' + ne + '*([*^$|!~]?=)' + ne + '*(?:\'((?:\\\\.|[^\\\\\'])*)\'|"((?:\\\\.|[^\\\\"])*)"|(' + re + '))|)' + ne + '*\\]',
    ie = ':(' + re + ')(?:\\(((\'((?:\\\\.|[^\\\\\'])*)\'|"((?:\\\\.|[^\\\\"])*)")|((?:\\\\.|[^\\\\()[\\]]|' + oe + ')*)|.*)\\)|)',
    ae = new RegExp(ne + '+', 'g'),
    se = new RegExp('^' + ne + '+|((?:^|[^\\\\])(?:\\\\.)*)' + ne + '+$', 'g'),
    le = new RegExp('^' + ne + '*,' + ne + '*'),
    ce = new RegExp('^' + ne + '*([>+~]|' + ne + ')' + ne + '*'),
    ue = new RegExp('=' + ne + '*([^\\]\'"]*?)' + ne + '*\\]', 'g'),
    de = new RegExp(ie),
    fe = new RegExp('^' + re + '$'),
    pe = {
      ID: new RegExp('^#(' + re + ')'),
      CLASS: new RegExp('^\\.(' + re + ')'),
      TAG: new RegExp('^(' + re + '|[*])'),
      ATTR: new RegExp('^' + oe),
      PSEUDO: new RegExp('^' + ie),
      CHILD: new RegExp('^:(only|first|last|nth|nth-last)-(child|of-type)(?:\\(' + ne + '*(even|odd|(([+-]|)(\\d*)n|)' + ne + '*(?:([+-]|)' + ne + '*(\\d+)|))' + ne + '*\\)|)', 'i'),
      bool: new RegExp('^(?:' + te + ')$', 'i'),
      needsContext: new RegExp('^' + ne + '*[>+~]|:(even|odd|eq|gt|lt|nth|first|last)(?:\\(' + ne + '*((?:-\\d)?\\d*)' + ne + '*\\)|)(?=[^-]|$)', 'i')
    },
    he = /^(?:input|select|textarea|button)$/i,
    me = /^h\d$/i,
    ge = /^[^{]+\{\s*\[native \w/,
    ve = /^(?:#([\w-]+)|(\w+)|\.([\w-]+))$/,
    ye = /[+~]/,
    xe = new RegExp('\\\\([\\da-f]{1,6}' + ne + '?|(' + ne + ')|.)', 'ig'),
    be = function (e, t, n) {
      var r = '0x' + t - 65536;
      return r !== r || n ? t : r < 0 ? String.fromCharCode(r + 65536)  : String.fromCharCode(r >> 10 | 55296, 1023 & r | 56320)
    },
    we = /([\0-\x1f\x7f]|^-?\d)|^-$|[^\0-\x1f\x7f-\uFFFF\w-]/g,
    Se = function (e, t) {
      return t ? '\0' === e ? '�' : e.slice(0, - 1) + '\\' + e.charCodeAt(e.length - 1).toString(16) + ' ' : '\\' + e
    },
    Ce = function () {
      B()
    },
    Te = h(function (e) {
      return !0 === e.disabled && ('form' in e || 'label' in e)
    }, {
      dir: 'parentNode',
      next: 'legend'
    });
    try {
      J.apply(G = Z.call(W.childNodes), W.childNodes),
      G[W.childNodes.length].nodeType
    } catch (e) {
      J = {
        apply: G.length ? function (e, t) {
          K.apply(e, Z.call(t))
        }
         : function (e, t) {
          for (var n = e.length, r = 0; e[n++] = t[r++]; );
          e.length = n - 1
        }
      }
    }
    S = t.support = {
    },
    k = t.isXML = function (e) {
      var t = e && (e.ownerDocument || e).documentElement;
      return !!t && 'HTML' !== t.nodeName
    },
    B = t.setDocument = function (e) {
      var t,
      n,
      r = e ? e.ownerDocument || e : W;
      return r !== O && 9 === r.nodeType && r.documentElement ? (O = r, L = O.documentElement, N = !k(O), W !== O && (n = O.defaultView) && n.top !== n && (n.addEventListener ? n.addEventListener('unload', Ce, !1)  : n.attachEvent && n.attachEvent('onunload', Ce)), S.attributes = o(function (e) {
        return e.className = 'i',
        !e.getAttribute('className')
      }), S.getElementsByTagName = o(function (e) {
        return e.appendChild(O.createComment('')),
        !e.getElementsByTagName('*').length
      }), S.getElementsByClassName = ge.test(O.getElementsByClassName), S.getById = o(function (e) {
        return L.appendChild(e).id = R,
        !O.getElementsByName || !O.getElementsByName(R).length
      }), S.getById ? (C.filter.ID = function (e) {
        var t = e.replace(xe, be);
        return function (e) {
          return e.getAttribute('id') === t
        }
      }, C.find.ID = function (e, t) {
        if (void 0 !== t.getElementById && N) {
          var n = t.getElementById(e);
          return n ? [
            n
          ] : [
          ]
        }
      })  : (C.filter.ID = function (e) {
        var t = e.replace(xe, be);
        return function (e) {
          var n = void 0 !== e.getAttributeNode && e.getAttributeNode('id');
          return n && n.value === t
        }
      }, C.find.ID = function (e, t) {
        if (void 0 !== t.getElementById && N) {
          var n,
          r,
          o,
          i = t.getElementById(e);
          if (i) {
            if ((n = i.getAttributeNode('id')) && n.value === e) return [i];
            for (o = t.getElementsByName(e), r = 0; i = o[r++]; ) if ((n = i.getAttributeNode('id')) && n.value === e) return [i]
          }
          return []
        }
      }), C.find.TAG = S.getElementsByTagName ? function (e, t) {
        return void 0 !== t.getElementsByTagName ? t.getElementsByTagName(e)  : S.qsa ? t.querySelectorAll(e)  : void 0
      }
       : function (e, t) {
        var n,
        r = [
        ],
        o = 0,
        i = t.getElementsByTagName(e);
        if ('*' === e) {
          for (; n = i[o++]; ) 1 === n.nodeType && r.push(n);
          return r
        }
        return i
      }, C.find.CLASS = S.getElementsByClassName && function (e, t) {
        if (void 0 !== t.getElementsByClassName && N) return t.getElementsByClassName(e)
      }, P = [
      ], I = [
      ], (S.qsa = ge.test(O.querySelectorAll)) && (o(function (e) {
        L.appendChild(e).innerHTML = '<a id=\'' + R + '\'></a><select id=\'' + R + '-\r\\\' msallowcapture=\'\'><option selected=\'\'></option></select>',
        e.querySelectorAll('[msallowcapture^=\'\']').length && I.push('[*^$]=' + ne + '*(?:\'\'|"")'),
        e.querySelectorAll('[selected]').length || I.push('\\[' + ne + '*(?:value|' + te + ')'),
        e.querySelectorAll('[id~=' + R + '-]').length || I.push('~='),
        e.querySelectorAll(':checked').length || I.push(':checked'),
        e.querySelectorAll('a#' + R + '+*').length || I.push('.#.+[+~]')
      }), o(function (e) {
        e.innerHTML = '<a href=\'\' disabled=\'disabled\'></a><select disabled=\'disabled\'><option/></select>';
        var t = O.createElement('input');
        t.setAttribute('type', 'hidden'),
        e.appendChild(t).setAttribute('name', 'D'),
        e.querySelectorAll('[name=d]').length && I.push('name' + ne + '*[*^$|!~]?='),
        2 !== e.querySelectorAll(':enabled').length && I.push(':enabled', ':disabled'),
        L.appendChild(e).disabled = !0,
        2 !== e.querySelectorAll(':disabled').length && I.push(':enabled', ':disabled'),
        e.querySelectorAll('*,:x'),
        I.push(',.*:')
      })), (S.matchesSelector = ge.test(H = L.matches || L.webkitMatchesSelector || L.mozMatchesSelector || L.oMatchesSelector || L.msMatchesSelector)) && o(function (e) {
        S.disconnectedMatch = H.call(e, '*'),
        H.call(e, '[s!=\'\']:x'),
        P.push('!=', ie)
      }), I = I.length && new RegExp(I.join('|')), P = P.length && new RegExp(P.join('|')), t = ge.test(L.compareDocumentPosition), q = t || ge.test(L.contains) ? function (e, t) {
        var n = 9 === e.nodeType ? e.documentElement : e,
        r = t && t.parentNode;
        return e === r || !(!r || 1 !== r.nodeType || !(n.contains ? n.contains(r)  : e.compareDocumentPosition && 16 & e.compareDocumentPosition(r)))
      }
       : function (e, t) {
        if (t) for (; t = t.parentNode; ) if (t === e) return !0;
        return !1
      }, Y = t ? function (e, t) {
        if (e === t) return j = !0,
        0;
        var n = !e.compareDocumentPosition - !t.compareDocumentPosition;
        return n || (1 & (n = (e.ownerDocument || e) === (t.ownerDocument || t) ? e.compareDocumentPosition(t)  : 1) || !S.sortDetached && t.compareDocumentPosition(e) === n ? e === O || e.ownerDocument === W && q(W, e) ? - 1 : t === O || t.ownerDocument === W && q(W, t) ? 1 : A ? ee(A, e) - ee(A, t)  : 0 : 4 & n ? - 1 : 1)
      }
       : function (e, t) {
        if (e === t) return j = !0,
        0;
        var n,
        r = 0,
        o = e.parentNode,
        i = t.parentNode,
        s = [
          e
        ],
        l = [
          t
        ];
        if (!o || !i) return e === O ? - 1 : t === O ? 1 : o ? - 1 : i ? 1 : A ? ee(A, e) - ee(A, t)  : 0;
        if (o === i) return a(e, t);
        for (n = e; n = n.parentNode; ) s.unshift(n);
        for (n = t; n = n.parentNode; ) l.unshift(n);
        for (; s[r] === l[r]; ) r++;
        return r ? a(s[r], l[r])  : s[r] === W ? - 1 : l[r] === W ? 1 : 0
      }, O)  : O
    },
    t.matches = function (e, n) {
      return t(e, null, null, n)
    },
    t.matchesSelector = function (e, n) {
      if ((e.ownerDocument || e) !== O && B(e), n = n.replace(ue, '=\'$1\']'), S.matchesSelector && N && !U[n + ' '] && (!P || !P.test(n)) && (!I || !I.test(n))) try {
        var r = H.call(e, n);
        if (r || S.disconnectedMatch || e.document && 11 !== e.document.nodeType) return r
      } catch (e) {
      }
      return t(n, O, null, [
        e
      ]).length > 0
    },
    t.contains = function (e, t) {
      return (e.ownerDocument || e) !== O && B(e),
      q(e, t)
    },
    t.attr = function (e, t) {
      (e.ownerDocument || e) !== O && B(e);
      var n = C.attrHandle[t.toLowerCase()],
      r = n && V.call(C.attrHandle, t.toLowerCase()) ? n(e, t, !N)  : void 0;
      return void 0 !== r ? r : S.attributes || !N ? e.getAttribute(t)  : (r = e.getAttributeNode(t)) && r.specified ? r.value : null
    },
    t.escape = function (e) {
      return (e + '').replace(we, Se)
    },
    t.error = function (e) {
      throw new Error('Syntax error, unrecognized expression: ' + e)
    },
    t.uniqueSort = function (e) {
      var t,
      n = [
      ],
      r = 0,
      o = 0;
      if (j = !S.detectDuplicates, A = !S.sortStable && e.slice(0), e.sort(Y), j) {
        for (; t = e[o++]; ) t === e[o] && (r = n.push(o));
        for (; r--; ) e.splice(n[r], 1)
      }
      return A = null,
      e
    },
    T = t.getText = function (e) {
      var t,
      n = '',
      r = 0,
      o = e.nodeType;
      if (o) {
        if (1 === o || 9 === o || 11 === o) {
          if ('string' == typeof e.textContent) return e.textContent;
          for (e = e.firstChild; e; e = e.nextSibling) n += T(e)
        } else if (3 === o || 4 === o) return e.nodeValue
      } else for (; t = e[r++]; ) n += T(t);
      return n
    },
    (C = t.selectors = {
      cacheLength: 50,
      createPseudo: r,
      match: pe,
      attrHandle: {
      },
      find: {
      },
      relative: {
        '>': {
          dir: 'parentNode',
          first: !0
        },
        ' ': {
          dir: 'parentNode'
        },
        '+': {
          dir: 'previousSibling',
          first: !0
        },
        '~': {
          dir: 'previousSibling'
        }
      },
      preFilter: {
        ATTR: function (e) {
          return e[1] = e[1].replace(xe, be),
          e[3] = (e[3] || e[4] || e[5] || '').replace(xe, be),
          '~=' === e[2] && (e[3] = ' ' + e[3] + ' '),
          e.slice(0, 4)
        },
        CHILD: function (e) {
          return e[1] = e[1].toLowerCase(),
          'nth' === e[1].slice(0, 3) ? (e[3] || t.error(e[0]), e[4] = + (e[4] ? e[5] + (e[6] || 1)  : 2 * ('even' === e[3] || 'odd' === e[3])), e[5] = + (e[7] + e[8] || 'odd' === e[3]))  : e[3] && t.error(e[0]),
          e
        },
        PSEUDO: function (e) {
          var t,
          n = !e[6] && e[2];
          return pe.CHILD.test(e[0]) ? null : (e[3] ? e[2] = e[4] || e[5] || '' : n && de.test(n) && (t = _(n, !0)) && (t = n.indexOf(')', n.length - t) - n.length) && (e[0] = e[0].slice(0, t), e[2] = n.slice(0, t)), e.slice(0, 3))
        }
      },
      filter: {
        TAG: function (e) {
          var t = e.replace(xe, be).toLowerCase();
          return '*' === e ? function () {
            return !0
          }
           : function (e) {
            return e.nodeName && e.nodeName.toLowerCase() === t
          }
        },
        CLASS: function (e) {
          var t = $[e + ' '];
          return t || (t = new RegExp('(^|' + ne + ')' + e + '(' + ne + '|$)')) && $(e, function (e) {
            return t.test('string' == typeof e.className && e.className || void 0 !== e.getAttribute && e.getAttribute('class') || '')
          })
        },
        ATTR: function (e, n, r) {
          return function (o) {
            var i = t.attr(o, e);
            return null == i ? '!=' === n : !n || (i += '', '=' === n ? i === r : '!=' === n ? i !== r : '^=' === n ? r && 0 === i.indexOf(r)  : '*=' === n ? r && i.indexOf(r) > - 1 : '$=' === n ? r && i.slice( - r.length) === r : '~=' === n ? (' ' + i.replace(ae, ' ') + ' ').indexOf(r) > - 1 : '|=' === n && (i === r || i.slice(0, r.length + 1) === r + '-'))
          }
        },
        CHILD: function (e, t, n, r, o) {
          var i = 'nth' !== e.slice(0, 3),
          a = 'last' !== e.slice( - 4),
          s = 'of-type' === t;
          return 1 === r && 0 === o ? function (e) {
            return !!e.parentNode
          }
           : function (t, n, l) {
            var c,
            u,
            d,
            f,
            p,
            h,
            m = i !== a ? 'nextSibling' : 'previousSibling',
            g = t.parentNode,
            v = s && t.nodeName.toLowerCase(),
            y = !l && !s,
            x = !1;
            if (g) {
              if (i) {
                for (; m; ) {
                  for (f = t; f = f[m]; ) if (s ? f.nodeName.toLowerCase() === v : 1 === f.nodeType) return !1;
                  h = m = 'only' === e && !h && 'nextSibling'
                }
                return !0
              }
              if (h = [
                a ? g.firstChild : g.lastChild
              ], a && y) {
                for (x = (p = (c = (u = (d = (f = g) [R] || (f[R] = {
                })) [f.uniqueID] || (d[f.uniqueID] = {
                })) [e] || [
                ]) [0] === z && c[1]) && c[2], f = p && g.childNodes[p]; f = ++p && f && f[m] || (x = p = 0) || h.pop(); ) if (1 === f.nodeType && ++x && f === t) {
                  u[e] = [
                    z,
                    p,
                    x
                  ];
                  break
                }
              } else if (y && (x = p = (c = (u = (d = (f = t) [R] || (f[R] = {
              })) [f.uniqueID] || (d[f.uniqueID] = {
              })) [e] || [
              ]) [0] === z && c[1]), !1 === x) for (; (f = ++p && f && f[m] || (x = p = 0) || h.pop()) && ((s ? f.nodeName.toLowerCase() !== v : 1 !== f.nodeType) || !++x || (y && ((u = (d = f[R] || (f[R] = {
              })) [f.uniqueID] || (d[f.uniqueID] = {
              })) [e] = [
                z,
                x
              ]), f !== t)); );
              return (x -= o) === r || x % r == 0 && x / r >= 0
            }
          }
        },
        PSEUDO: function (e, n) {
          var o,
          i = C.pseudos[e] || C.setFilters[e.toLowerCase()] || t.error('unsupported pseudo: ' + e);
          return i[R] ? i(n)  : i.length > 1 ? (o = [
            e,
            e,
            '',
            n
          ], C.setFilters.hasOwnProperty(e.toLowerCase()) ? r(function (e, t) {
            for (var r, o = i(e, n), a = o.length; a--; ) e[r = ee(e, o[a])] = !(t[r] = o[a])
          })  : function (e) {
            return i(e, 0, o)
          })  : i
        }
      },
      pseudos: {
        not: r(function (e) {
          var t = [
          ],
          n = [
          ],
          o = D(e.replace(se, '$1'));
          return o[R] ? r(function (e, t, n, r) {
            for (var i, a = o(e, null, r, [
            ]), s = e.length; s--; ) (i = a[s]) && (e[s] = !(t[s] = i))
          })  : function (e, r, i) {
            return t[0] = e,
            o(t, null, i, n),
            t[0] = null,
            !n.pop()
          }
        }),
        has: r(function (e) {
          return function (n) {
            return t(e, n).length > 0
          }
        }),
        contains: r(function (e) {
          return e = e.replace(xe, be),
          function (t) {
            return (t.textContent || t.innerText || T(t)).indexOf(e) > - 1
          }
        }),
        lang: r(function (e) {
          return fe.test(e || '') || t.error('unsupported lang: ' + e),
          e = e.replace(xe, be).toLowerCase(),
          function (t) {
            var n;
            do {
              if (n = N ? t.lang : t.getAttribute('xml:lang') || t.getAttribute('lang')) return (n = n.toLowerCase()) === e || 0 === n.indexOf(e + '-')
            } while ((t = t.parentNode) && 1 === t.nodeType);
            return !1
          }
        }),
        target: function (t) {
          var n = e.location && e.location.hash;
          return n && n.slice(1) === t.id
        },
        root: function (e) {
          return e === L
        },
        focus: function (e) {
          return e === O.activeElement && (!O.hasFocus || O.hasFocus()) && !!(e.type || e.href || ~e.tabIndex)
        },
        enabled: c(!1),
        disabled: c(!0),
        checked: function (e) {
          var t = e.nodeName.toLowerCase();
          return 'input' === t && !!e.checked || 'option' === t && !!e.selected
        },
        selected: function (e) {
          return e.parentNode && e.parentNode.selectedIndex,
          !0 === e.selected
        },
        empty: function (e) {
          for (e = e.firstChild; e; e = e.nextSibling) if (e.nodeType < 6) return !1;
          return !0
        },
        parent: function (e) {
          return !C.pseudos.empty(e)
        },
        header: function (e) {
          return me.test(e.nodeName)
        },
        input: function (e) {
          return he.test(e.nodeName)
        },
        button: function (e) {
          var t = e.nodeName.toLowerCase();
          return 'input' === t && 'button' === e.type || 'button' === t
        },
        text: function (e) {
          var t;
          return 'input' === e.nodeName.toLowerCase() && 'text' === e.type && (null == (t = e.getAttribute('type')) || 'text' === t.toLowerCase())
        },
        first: u(function () {
          return [0]
        }),
        last: u(function (e, t) {
          return [t - 1]
        }),
        eq: u(function (e, t, n) {
          return [n < 0 ? n + t : n]
        }),
        even: u(function (e, t) {
          for (var n = 0; n < t; n += 2) e.push(n);
          return e
        }),
        odd: u(function (e, t) {
          for (var n = 1; n < t; n += 2) e.push(n);
          return e
        }),
        lt: u(function (e, t, n) {
          for (var r = n < 0 ? n + t : n; --r >= 0; ) e.push(r);
          return e
        }),
        gt: u(function (e, t, n) {
          for (var r = n < 0 ? n + t : n; ++r < t; ) e.push(r);
          return e
        })
      }
    }).pseudos.nth = C.pseudos.eq;
    for (w in {
      radio: !0,
      checkbox: !0,
      file: !0,
      password: !0,
      image: !0
    }) C.pseudos[w] = s(w);
    for (w in {
      submit: !0,
      reset: !0
    }) C.pseudos[w] = l(w);
    return f.prototype = C.filters = C.pseudos,
    C.setFilters = new f,
    _ = t.tokenize = function (e, n) {
      var r,
      o,
      i,
      a,
      s,
      l,
      c,
      u = X[e + ' '];
      if (u) return n ? 0 : u.slice(0);
      for (s = e, l = [
      ], c = C.preFilter; s; ) {
        r && !(o = le.exec(s)) || (o && (s = s.slice(o[0].length) || s), l.push(i = [
        ])),
        r = !1,
        (o = ce.exec(s)) && (r = o.shift(), i.push({
          value: r,
          type: o[0].replace(se, ' ')
        }), s = s.slice(r.length));
        for (a in C.filter) !(o = pe[a].exec(s)) || c[a] && !(o = c[a](o)) || (r = o.shift(), i.push({
          value: r,
          type: a,
          matches: o
        }), s = s.slice(r.length));
        if (!r) break
      }
      return n ? s.length : s ? t.error(e)  : X(e, l).slice(0)
    },
    D = t.compile = function (e, t) {
      var n,
      r = [
      ],
      o = [
      ],
      i = U[e + ' '];
      if (!i) {
        for (t || (t = _(e)), n = t.length; n--; ) (i = x(t[n])) [R] ? r.push(i)  : o.push(i);
        (i = U(e, b(o, r))).selector = e
      }
      return i
    },
    E = t.select = function (e, t, n, r) {
      var o,
      i,
      a,
      s,
      l,
      c = 'function' == typeof e && e,
      u = !r && _(e = c.selector || e);
      if (n = n || [
      ], 1 === u.length) {
        if ((i = u[0] = u[0].slice(0)).length > 2 && 'ID' === (a = i[0]).type && 9 === t.nodeType && N && C.relative[i[1].type]) {
          if (!(t = (C.find.ID(a.matches[0].replace(xe, be), t) || [
          ]) [0])) return n;
          c && (t = t.parentNode),
          e = e.slice(i.shift().value.length)
        }
        for (o = pe.needsContext.test(e) ? 0 : i.length; o-- && (a = i[o], !C.relative[s = a.type]); ) if ((l = C.find[s]) && (r = l(a.matches[0].replace(xe, be), ye.test(i[0].type) && d(t.parentNode) || t))) {
          if (i.splice(o, 1), !(e = r.length && p(i))) return J.apply(n, r),
          n;
          break
        }
      }
      return (c || D(e, u)) (r, t, !N, n, !t || ye.test(e) && d(t.parentNode) || t),
      n
    },
    S.sortStable = R.split('').sort(Y).join('') === R,
    S.detectDuplicates = !!j,
    B(),
    S.sortDetached = o(function (e) {
      return 1 & e.compareDocumentPosition(O.createElement('fieldset'))
    }),
    o(function (e) {
      return e.innerHTML = '<a href=\'#\'></a>',
      '#' === e.firstChild.getAttribute('href')
    }) || i('type|href|height|width', function (e, t, n) {
      if (!n) return e.getAttribute(t, 'type' === t.toLowerCase() ? 1 : 2)
    }),
    S.attributes && o(function (e) {
      return e.innerHTML = '<input/>',
      e.firstChild.setAttribute('value', ''),
      '' === e.firstChild.getAttribute('value')
    }) || i('value', function (e, t, n) {
      if (!n && 'input' === e.nodeName.toLowerCase()) return e.defaultValue
    }),
    o(function (e) {
      return null == e.getAttribute('disabled')
    }) || i(te, function (e, t, n) {
      var r;
      if (!n) return !0 === e[t] ? t.toLowerCase()  : (r = e.getAttributeNode(t)) && r.specified ? r.value : null
    }),
    t
  }(e);
  we.find = Ce,
  we.expr = Ce.selectors,
  we.expr[':'] = we.expr.pseudos,
  we.uniqueSort = we.unique = Ce.uniqueSort,
  we.text = Ce.getText,
  we.isXMLDoc = Ce.isXML,
  we.contains = Ce.contains,
  we.escapeSelector = Ce.escape;
  var Te = function (e, t, n) {
    for (var r = [
    ], o = void 0 !== n; (e = e[t]) && 9 !== e.nodeType; ) if (1 === e.nodeType) {
      if (o && we(e).is(n)) break;
      r.push(e)
    }
    return r
  },
  ke = function (e, t) {
    for (var n = [
    ]; e; e = e.nextSibling) 1 === e.nodeType && e !== t && n.push(e);
    return n
  },
  _e = we.expr.match.needsContext,
  De = /^<([a-z][^\/\0>:\x20\t\r\n\f]*)[\x20\t\r\n\f]*\/?>(?:<\/\1>|)$/i;
  we.filter = function (e, t, n) {
    var r = t[0];
    return n && (e = ':not(' + e + ')'),
    1 === t.length && 1 === r.nodeType ? we.find.matchesSelector(r, e) ? [
      r
    ] : [
    ] : we.find.matches(e, we.grep(t, function (e) {
      return 1 === e.nodeType
    }))
  },
  we.fn.extend({
    find: function (e) {
      var t,
      n,
      r = this.length,
      o = this;
      if ('string' != typeof e) return this.pushStack(we(e).filter(function () {
        for (t = 0; t < r; t++) if (we.contains(o[t], this)) return !0
      }));
      for (n = this.pushStack([]), t = 0; t < r; t++) we.find(e, o[t], n);
      return r > 1 ? we.uniqueSort(n)  : n
    },
    filter: function (e) {
      return this.pushStack(a(this, e || [
      ], !1))
    },
    not: function (e) {
      return this.pushStack(a(this, e || [
      ], !0))
    },
    is: function (e) {
      return !!a(this, 'string' == typeof e && _e.test(e) ? we(e)  : e || [
      ], !1).length
    }
  });
  var Ee,
  Me = /^(?:\s*(<[\w\W]+>)[^>]*|#([\w-]+))$/;
  (we.fn.init = function (e, t, n) {
    var r,
    o;
    if (!e) return this;
    if (n = n || Ee, 'string' == typeof e) {
      if (!(r = '<' === e[0] && '>' === e[e.length - 1] && e.length >= 3 ? [
        null,
        e,
        null
      ] : Me.exec(e)) || !r[1] && t) return !t || t.jquery ? (t || n).find(e)  : this.constructor(t).find(e);
      if (r[1]) {
        if (t = t instanceof we ? t[0] : t, we.merge(this, we.parseHTML(r[1], t && t.nodeType ? t.ownerDocument || t : ae, !0)), De.test(r[1]) && we.isPlainObject(t)) for (r in t) ye(this[r]) ? this[r](t[r])  : this.attr(r, t[r]);
        return this
      }
      return (o = ae.getElementById(r[2])) && (this[0] = o, this.length = 1),
      this
    }
    return e.nodeType ? (this[0] = e, this.length = 1, this)  : ye(e) ? void 0 !== n.ready ? n.ready(e)  : e(we)  : we.makeArray(e, this)
  }).prototype = we.fn,
  Ee = we(ae);
  var Ae = /^(?:parents|prev(?:Until|All))/,
  je = {
    children: !0,
    contents: !0,
    next: !0,
    prev: !0
  };
  we.fn.extend({
    has: function (e) {
      var t = we(e, this),
      n = t.length;
      return this.filter(function () {
        for (var e = 0; e < n; e++) if (we.contains(this, t[e])) return !0
      })
    },
    closest: function (e, t) {
      var n,
      r = 0,
      o = this.length,
      i = [
      ],
      a = 'string' != typeof e && we(e);
      if (!_e.test(e)) for (; r < o; r++) for (n = this[r]; n && n !== t; n = n.parentNode) if (n.nodeType < 11 && (a ? a.index(n) > - 1 : 1 === n.nodeType && we.find.matchesSelector(n, e))) {
        i.push(n);
        break
      }
      return this.pushStack(i.length > 1 ? we.uniqueSort(i)  : i)
    },
    index: function (e) {
      return e ? 'string' == typeof e ? de.call(we(e), this[0])  : de.call(this, e.jquery ? e[0] : e)  : this[0] && this[0].parentNode ? this.first().prevAll().length : - 1
    },
    add: function (e, t) {
      return this.pushStack(we.uniqueSort(we.merge(this.get(), we(e, t))))
    },
    addBack: function (e) {
      return this.add(null == e ? this.prevObject : this.prevObject.filter(e))
    }
  }),
  we.each({
    parent: function (e) {
      var t = e.parentNode;
      return t && 11 !== t.nodeType ? t : null
    },
    parents: function (e) {
      return Te(e, 'parentNode')
    },
    parentsUntil: function (e, t, n) {
      return Te(e, 'parentNode', n)
    },
    next: function (e) {
      return s(e, 'nextSibling')
    },
    prev: function (e) {
      return s(e, 'previousSibling')
    },
    nextAll: function (e) {
      return Te(e, 'nextSibling')
    },
    prevAll: function (e) {
      return Te(e, 'previousSibling')
    },
    nextUntil: function (e, t, n) {
      return Te(e, 'nextSibling', n)
    },
    prevUntil: function (e, t, n) {
      return Te(e, 'previousSibling', n)
    },
    siblings: function (e) {
      return ke((e.parentNode || {
      }).firstChild, e)
    },
    children: function (e) {
      return ke(e.firstChild)
    },
    contents: function (e) {
      return i(e, 'iframe') ? e.contentDocument : (i(e, 'template') && (e = e.content || e), we.merge([], e.childNodes))
    }
  }, function (e, t) {
    we.fn[e] = function (n, r) {
      var o = we.map(this, t, n);
      return 'Until' !== e.slice( - 5) && (r = n),
      r && 'string' == typeof r && (o = we.filter(r, o)),
      this.length > 1 && (je[e] || we.uniqueSort(o), Ae.test(e) && o.reverse()),
      this.pushStack(o)
    }
  });
  var Be = /[^\x20\t\r\n\f]+/g;
  we.Callbacks = function (e) {
    e = 'string' == typeof e ? l(e)  : we.extend({
    }, e);
    var t,
    n,
    o,
    i,
    a = [
    ],
    s = [
    ],
    c = - 1,
    u = function () {
      for (i = i || e.once, o = t = !0; s.length; c = - 1) for (n = s.shift(); ++c < a.length; ) !1 === a[c].apply(n[0], n[1]) && e.stopOnFalse && (c = a.length, n = !1);
      e.memory || (n = !1),
      t = !1,
      i && (a = n ? [
      ] : '')
    },
    d = {
      add: function () {
        return a && (n && !t && (c = a.length - 1, s.push(n)), function t(n) {
          we.each(n, function (n, o) {
            ye(o) ? e.unique && d.has(o) || a.push(o)  : o && o.length && 'string' !== r(o) && t(o)
          })
        }(arguments), n && !t && u()),
        this
      },
      remove: function () {
        return we.each(arguments, function (e, t) {
          for (var n; (n = we.inArray(t, a, n)) > - 1; ) a.splice(n, 1),
          n <= c && c--
        }),
        this
      },
      has: function (e) {
        return e ? we.inArray(e, a) > - 1 : a.length > 0
      },
      empty: function () {
        return a && (a = [
        ]),
        this
      },
      disable: function () {
        return i = s = [
        ],
        a = n = '',
        this
      },
      disabled: function () {
        return !a
      },
      lock: function () {
        return i = s = [
        ],
        n || t || (a = n = ''),
        this
      },
      locked: function () {
        return !!i
      },
      fireWith: function (e, n) {
        return i || (n = [
          e,
          (n = n || [
          ]).slice ? n.slice()  : n
        ], s.push(n), t || u()),
        this
      },
      fire: function () {
        return d.fireWith(this, arguments),
        this
      },
      fired: function () {
        return !!o
      }
    };
    return d
  },
  we.extend({
    Deferred: function (t) {
      var n = [
        ['notify',
        'progress',
        we.Callbacks('memory'),
        we.Callbacks('memory'),
        2],
        [
          'resolve',
          'done',
          we.Callbacks('once memory'),
          we.Callbacks('once memory'),
          0,
          'resolved'
        ],
        [
          'reject',
          'fail',
          we.Callbacks('once memory'),
          we.Callbacks('once memory'),
          1,
          'rejected'
        ]
      ],
      r = 'pending',
      o = {
        state: function () {
          return r
        },
        always: function () {
          return i.done(arguments).fail(arguments),
          this
        },
        catch : function (e) {
          return o.then(null, e)
        },
        pipe: function () {
          var e = arguments;
          return we.Deferred(function (t) {
            we.each(n, function (n, r) {
              var o = ye(e[r[4]]) && e[r[4]];
              i[r[1]](function () {
                var e = o && o.apply(this, arguments);
                e && ye(e.promise) ? e.promise().progress(t.notify).done(t.resolve).fail(t.reject)  : t[r[0] + 'With'](this, o ? [
                  e
                ] : arguments)
              })
            }),
            e = null
          }).promise()
        },
        then: function (t, r, o) {
          function i(t, n, r, o) {
            return function () {
              var s = this,
              l = arguments,
              d = function () {
                var e,
                d;
                if (!(t < a)) {
                  if ((e = r.apply(s, l)) === n.promise()) throw new TypeError('Thenable self-resolution');
                  d = e && ('object' == typeof e || 'function' == typeof e) && e.then,
                  ye(d) ? o ? d.call(e, i(a, n, c, o), i(a, n, u, o))  : (a++, d.call(e, i(a, n, c, o), i(a, n, u, o), i(a, n, c, n.notifyWith)))  : (r !== c && (s = void 0, l = [
                    e
                  ]), (o || n.resolveWith) (s, l))
                }
              },
              f = o ? d : function () {
                try {
                  d()
                } catch (e) {
                  we.Deferred.exceptionHook && we.Deferred.exceptionHook(e, f.stackTrace),
                  t + 1 >= a && (r !== u && (s = void 0, l = [
                    e
                  ]), n.rejectWith(s, l))
                }
              };
              t ? f()  : (we.Deferred.getStackHook && (f.stackTrace = we.Deferred.getStackHook()), e.setTimeout(f))
            }
          }
          var a = 0;
          return we.Deferred(function (e) {
            n[0][3].add(i(0, e, ye(o) ? o : c, e.notifyWith)),
            n[1][3].add(i(0, e, ye(t) ? t : c)),
            n[2][3].add(i(0, e, ye(r) ? r : u))
          }).promise()
        },
        promise: function (e) {
          return null != e ? we.extend(e, o)  : o
        }
      },
      i = {
      };
      return we.each(n, function (e, t) {
        var a = t[2],
        s = t[5];
        o[t[1]] = a.add,
        s && a.add(function () {
          r = s
        }, n[3 - e][2].disable, n[3 - e][3].disable, n[0][2].lock, n[0][3].lock),
        a.add(t[3].fire),
        i[t[0]] = function () {
          return i[t[0] + 'With'](this === i ? void 0 : this, arguments),
          this
        },
        i[t[0] + 'With'] = a.fireWith
      }),
      o.promise(i),
      t && t.call(i, i),
      i
    },
    when: function (e) {
      var t = arguments.length,
      n = t,
      r = Array(n),
      o = le.call(arguments),
      i = we.Deferred(),
      a = function (e) {
        return function (n) {
          r[e] = this,
          o[e] = arguments.length > 1 ? le.call(arguments)  : n,
          --t || i.resolveWith(r, o)
        }
      };
      if (t <= 1 && (d(e, i.done(a(n)).resolve, i.reject, !t), 'pending' === i.state() || ye(o[n] && o[n].then))) return i.then();
      for (; n--; ) d(o[n], a(n), i.reject);
      return i.promise()
    }
  });
  var Oe = /^(Eval|Internal|Range|Reference|Syntax|Type|URI)Error$/;
  we.Deferred.exceptionHook = function (t, n) {
    e.console && e.console.warn && t && Oe.test(t.name) && e.console.warn('jQuery.Deferred exception: ' + t.message, t.stack, n)
  },
  we.readyException = function (t) {
    e.setTimeout(function () {
      throw t
    })
  };
  var Le = we.Deferred();
  we.fn.ready = function (e) {
    return Le.then(e).catch (function (e) {
      we.readyException(e)
    }),
    this
  },
  we.extend({
    isReady: !1,
    readyWait: 1,
    ready: function (e) {
      (!0 === e ? --we.readyWait : we.isReady) || (we.isReady = !0, !0 !== e && --we.readyWait > 0 || Le.resolveWith(ae, [
        we
      ]))
    }
  }),
  we.ready.then = Le.then,
  'complete' === ae.readyState || 'loading' !== ae.readyState && !ae.documentElement.doScroll ? e.setTimeout(we.ready)  : (ae.addEventListener('DOMContentLoaded', f), e.addEventListener('load', f));
  var Ne = function (e, t, n, o, i, a, s) {
    var l = 0,
    c = e.length,
    u = null == n;
    if ('object' === r(n)) {
      i = !0;
      for (l in n) Ne(e, t, l, n[l], !0, a, s)
    } else if (void 0 !== o && (i = !0, ye(o) || (s = !0), u && (s ? (t.call(e, o), t = null)  : (u = t, t = function (e, t, n) {
      return u.call(we(e), n)
    })), t)) for (; l < c; l++) t(e[l], n, s ? o : o.call(e[l], l, t(e[l], n)));
    return i ? e : u ? t.call(e)  : c ? t(e[0], n)  : a
  },
  Ie = /^-ms-/,
  Pe = /-([a-z])/g,
  He = function (e) {
    return 1 === e.nodeType || 9 === e.nodeType || ! + e.nodeType
  };
  m.uid = 1,
  m.prototype = {
    cache: function (e) {
      var t = e[this.expando];
      return t || (t = {
      }, He(e) && (e.nodeType ? e[this.expando] = t : Object.defineProperty(e, this.expando, {
        value: t,
        configurable: !0
      }))),
      t
    },
    set: function (e, t, n) {
      var r,
      o = this.cache(e);
      if ('string' == typeof t) o[h(t)] = n;
       else for (r in t) o[h(r)] = t[r];
      return o
    },
    get: function (e, t) {
      return void 0 === t ? this.cache(e)  : e[this.expando] && e[this.expando][h(t)]
    },
    access: function (e, t, n) {
      return void 0 === t || t && 'string' == typeof t && void 0 === n ? this.get(e, t)  : (this.set(e, t, n), void 0 !== n ? n : t)
    },
    remove: function (e, t) {
      var n,
      r = e[this.expando];
      if (void 0 !== r) {
        if (void 0 !== t) {
          n = (t = Array.isArray(t) ? t.map(h)  : (t = h(t)) in r ? [
            t
          ] : t.match(Be) || [
          ]).length;
          for (; n--; ) delete r[t[n]]
        }(void 0 === t || we.isEmptyObject(r)) && (e.nodeType ? e[this.expando] = void 0 : delete e[this.expando])
      }
    },
    hasData: function (e) {
      var t = e[this.expando];
      return void 0 !== t && !we.isEmptyObject(t)
    }
  };
  var qe = new m,
  Re = new m,
  We = /^(?:\{[\w\W]*\}|\[[\w\W]*\])$/,
  ze = /[A-Z]/g;
  we.extend({
    hasData: function (e) {
      return Re.hasData(e) || qe.hasData(e)
    },
    data: function (e, t, n) {
      return Re.access(e, t, n)
    },
    removeData: function (e, t) {
      Re.remove(e, t)
    },
    _data: function (e, t, n) {
      return qe.access(e, t, n)
    },
    _removeData: function (e, t) {
      qe.remove(e, t)
    }
  }),
  we.fn.extend({
    data: function (e, t) {
      var n,
      r,
      o,
      i = this[0],
      a = i && i.attributes;
      if (void 0 === e) {
        if (this.length && (o = Re.get(i), 1 === i.nodeType && !qe.get(i, 'hasDataAttrs'))) {
          for (n = a.length; n--; ) a[n] && 0 === (r = a[n].name).indexOf('data-') && (r = h(r.slice(5)), v(i, r, o[r]));
          qe.set(i, 'hasDataAttrs', !0)
        }
        return o
      }
      return 'object' == typeof e ? this.each(function () {
        Re.set(this, e)
      })  : Ne(this, function (t) {
        var n;
        if (i && void 0 === t) {
          if (void 0 !== (n = Re.get(i, e))) return n;
          if (void 0 !== (n = v(i, e))) return n
        } else this.each(function () {
          Re.set(this, e, t)
        })
      }, null, t, arguments.length > 1, null, !0)
    },
    removeData: function (e) {
      return this.each(function () {
        Re.remove(this, e)
      })
    }
  }),
  we.extend({
    queue: function (e, t, n) {
      var r;
      if (e) return t = (t || 'fx') + 'queue',
      r = qe.get(e, t),
      n && (!r || Array.isArray(n) ? r = qe.access(e, t, we.makeArray(n))  : r.push(n)),
      r || [
      ]
    },
    dequeue: function (e, t) {
      t = t || 'fx';
      var n = we.queue(e, t),
      r = n.length,
      o = n.shift(),
      i = we._queueHooks(e, t),
      a = function () {
        we.dequeue(e, t)
      };
      'inprogress' === o && (o = n.shift(), r--),
      o && ('fx' === t && n.unshift('inprogress'), delete i.stop, o.call(e, a, i)),
      !r && i && i.empty.fire()
    },
    _queueHooks: function (e, t) {
      var n = t + 'queueHooks';
      return qe.get(e, n) || qe.access(e, n, {
        empty: we.Callbacks('once memory').add(function () {
          qe.remove(e, [
            t + 'queue',
            n
          ])
        })
      })
    }
  }),
  we.fn.extend({
    queue: function (e, t) {
      var n = 2;
      return 'string' != typeof e && (t = e, e = 'fx', n--),
      arguments.length < n ? we.queue(this[0], e)  : void 0 === t ? this : this.each(function () {
        var n = we.queue(this, e, t);
        we._queueHooks(this, e),
        'fx' === e && 'inprogress' !== n[0] && we.dequeue(this, e)
      })
    },
    dequeue: function (e) {
      return this.each(function () {
        we.dequeue(this, e)
      })
    },
    clearQueue: function (e) {
      return this.queue(e || 'fx', [
      ])
    },
    promise: function (e, t) {
      var n,
      r = 1,
      o = we.Deferred(),
      i = this,
      a = this.length,
      s = function () {
        --r || o.resolveWith(i, [
          i
        ])
      };
      for ('string' != typeof e && (t = e, e = void 0), e = e || 'fx'; a--; ) (n = qe.get(i[a], e + 'queueHooks')) && n.empty && (r++, n.empty.add(s));
      return s(),
      o.promise(t)
    }
  });
  var Fe = /[+-]?(?:\d*\.|)\d+(?:[eE][+-]?\d+|)/.source,
  $e = new RegExp('^(?:([+-])=|)(' + Fe + ')([a-z%]*)$', 'i'),
  Xe = [
    'Top',
    'Right',
    'Bottom',
    'Left'
  ],
  Ue = function (e, t) {
    return 'none' === (e = t || e).style.display || '' === e.style.display && we.contains(e.ownerDocument, e) && 'none' === we.css(e, 'display')
  },
  Ye = function (e, t, n, r) {
    var o,
    i,
    a = {
    };
    for (i in t) a[i] = e.style[i],
    e.style[i] = t[i];
    o = n.apply(e, r || [
    ]);
    for (i in t) e.style[i] = a[i];
    return o
  },
  Ve = {
  };
  we.fn.extend({
    show: function () {
      return b(this, !0)
    },
    hide: function () {
      return b(this)
    },
    toggle: function (e) {
      return 'boolean' == typeof e ? e ? this.show()  : this.hide()  : this.each(function () {
        Ue(this) ? we(this).show()  : we(this).hide()
      })
    }
  });
  var Ge = /^(?:checkbox|radio)$/i,
  Qe = /<([a-z][^\/\0>\x20\t\r\n\f]+)/i,
  Ke = /^$|^module$|\/(?:java|ecma)script/i,
  Je = {
    option: [
      1,
      '<select multiple=\'multiple\'>',
      '</select>'
    ],
    thead: [
      1,
      '<table>',
      '</table>'
    ],
    col: [
      2,
      '<table><colgroup>',
      '</colgroup></table>'
    ],
    tr: [
      2,
      '<table><tbody>',
      '</tbody></table>'
    ],
    td: [
      3,
      '<table><tbody><tr>',
      '</tr></tbody></table>'
    ],
    _default: [
      0,
      '',
      ''
    ]
  };
  Je.optgroup = Je.option,
  Je.tbody = Je.tfoot = Je.colgroup = Je.caption = Je.thead,
  Je.th = Je.td;
  var Ze = /<|&#?\w+;/;
  !function () {
    var e = ae.createDocumentFragment().appendChild(ae.createElement('div')),
    t = ae.createElement('input');
    t.setAttribute('type', 'radio'),
    t.setAttribute('checked', 'checked'),
    t.setAttribute('name', 't'),
    e.appendChild(t),
    ve.checkClone = e.cloneNode(!0).cloneNode(!0).lastChild.checked,
    e.innerHTML = '<textarea>x</textarea>',
    ve.noCloneChecked = !!e.cloneNode(!0).lastChild.defaultValue
  }();
  var et = ae.documentElement,
  tt = /^key/,
  nt = /^(?:mouse|pointer|contextmenu|drag|drop)|click/,
  rt = /^([^.]*)(?:\.(.+)|)/;
  we.event = {
    global: {
    },
    add: function (e, t, n, r, o) {
      var i,
      a,
      s,
      l,
      c,
      u,
      d,
      f,
      p,
      h,
      m,
      g = qe.get(e);
      if (g) for (n.handler && (n = (i = n).handler, o = i.selector), o && we.find.matchesSelector(et, o), n.guid || (n.guid = we.guid++), (l = g.events) || (l = g.events = {
      }), (a = g.handle) || (a = g.handle = function (t) {
        return void 0 !== we && we.event.triggered !== t.type ? we.event.dispatch.apply(e, arguments)  : void 0
      }), c = (t = (t || '').match(Be) || [
        ''
      ]).length; c--; ) p = m = (s = rt.exec(t[c]) || [
      ]) [1],
      h = (s[2] || '').split('.').sort(),
      p && (d = we.event.special[p] || {
      }, p = (o ? d.delegateType : d.bindType) || p, d = we.event.special[p] || {
      }, u = we.extend({
        type: p,
        origType: m,
        data: r,
        handler: n,
        guid: n.guid,
        selector: o,
        needsContext: o && we.expr.match.needsContext.test(o),
        namespace: h.join('.')
      }, i), (f = l[p]) || ((f = l[p] = [
      ]).delegateCount = 0, d.setup && !1 !== d.setup.call(e, r, h, a) || e.addEventListener && e.addEventListener(p, a)), d.add && (d.add.call(e, u), u.handler.guid || (u.handler.guid = n.guid)), o ? f.splice(f.delegateCount++, 0, u)  : f.push(u), we.event.global[p] = !0)
    },
    remove: function (e, t, n, r, o) {
      var i,
      a,
      s,
      l,
      c,
      u,
      d,
      f,
      p,
      h,
      m,
      g = qe.hasData(e) && qe.get(e);
      if (g && (l = g.events)) {
        for (c = (t = (t || '').match(Be) || [
          ''
        ]).length; c--; ) if (s = rt.exec(t[c]) || [
        ], p = m = s[1], h = (s[2] || '').split('.').sort(), p) {
          for (d = we.event.special[p] || {
          }, f = l[p = (r ? d.delegateType : d.bindType) || p] || [
          ], s = s[2] && new RegExp('(^|\\.)' + h.join('\\.(?:.*\\.|)') + '(\\.|$)'), a = i = f.length; i--; ) u = f[i],
          !o && m !== u.origType || n && n.guid !== u.guid || s && !s.test(u.namespace) || r && r !== u.selector && ('**' !== r || !u.selector) || (f.splice(i, 1), u.selector && f.delegateCount--, d.remove && d.remove.call(e, u));
          a && !f.length && (d.teardown && !1 !== d.teardown.call(e, h, g.handle) || we.removeEvent(e, p, g.handle), delete l[p])
        } else for (p in l) we.event.remove(e, p + t[c], n, r, !0);
        we.isEmptyObject(l) && qe.remove(e, 'handle events')
      }
    },
    dispatch: function (e) {
      var t,
      n,
      r,
      o,
      i,
      a,
      s = we.event.fix(e),
      l = new Array(arguments.length),
      c = (qe.get(this, 'events') || {
      }) [s.type] || [
      ],
      u = we.event.special[s.type] || {
      };
      for (l[0] = s, t = 1; t < arguments.length; t++) l[t] = arguments[t];
      if (s.delegateTarget = this, !u.preDispatch || !1 !== u.preDispatch.call(this, s)) {
        for (a = we.event.handlers.call(this, s, c), t = 0; (o = a[t++]) && !s.isPropagationStopped(); ) for (s.currentTarget = o.elem, n = 0; (i = o.handlers[n++]) && !s.isImmediatePropagationStopped(); ) s.rnamespace && !s.rnamespace.test(i.namespace) || (s.handleObj = i, s.data = i.data, void 0 !== (r = ((we.event.special[i.origType] || {
        }).handle || i.handler).apply(o.elem, l)) && !1 === (s.result = r) && (s.preventDefault(), s.stopPropagation()));
        return u.postDispatch && u.postDispatch.call(this, s),
        s.result
      }
    },
    handlers: function (e, t) {
      var n,
      r,
      o,
      i,
      a,
      s = [
      ],
      l = t.delegateCount,
      c = e.target;
      if (l && c.nodeType && !('click' === e.type && e.button >= 1)) for (; c !== this; c = c.parentNode || this) if (1 === c.nodeType && ('click' !== e.type || !0 !== c.disabled)) {
        for (i = [
        ], a = {
        }, n = 0; n < l; n++) void 0 === a[o = (r = t[n]).selector + ' '] && (a[o] = r.needsContext ? we(o, this).index(c) > - 1 : we.find(o, this, null, [
          c
        ]).length),
        a[o] && i.push(r);
        i.length && s.push({
          elem: c,
          handlers: i
        })
      }
      return c = this,
      l < t.length && s.push({
        elem: c,
        handlers: t.slice(l)
      }),
      s
    },
    addProp: function (e, t) {
      Object.defineProperty(we.Event.prototype, e, {
        enumerable: !0,
        configurable: !0,
        get: ye(t) ? function () {
          if (this.originalEvent) return t(this.originalEvent)
        }
         : function () {
          if (this.originalEvent) return this.originalEvent[e]
        },
        set: function (t) {
          Object.defineProperty(this, e, {
            enumerable: !0,
            configurable: !0,
            writable: !0,
            value: t
          })
        }
      })
    },
    fix: function (e) {
      return e[we.expando] ? e : new we.Event(e)
    },
    special: {
      load: {
        noBubble: !0
      },
      focus: {
        trigger: function () {
          if (this !== _() && this.focus) return this.focus(),
          !1
        },
        delegateType: 'focusin'
      },
      blur: {
        trigger: function () {
          if (this === _() && this.blur) return this.blur(),
          !1
        },
        delegateType: 'focusout'
      },
      click: {
        trigger: function () {
          if ('checkbox' === this.type && this.click && i(this, 'input')) return this.click(),
          !1
        },
        _default: function (e) {
          return i(e.target, 'a')
        }
      },
      beforeunload: {
        postDispatch: function (e) {
          void 0 !== e.result && e.originalEvent && (e.originalEvent.returnValue = e.result)
        }
      }
    }
  },
  we.removeEvent = function (e, t, n) {
    e.removeEventListener && e.removeEventListener(t, n)
  },
  we.Event = function (e, t) {
    if (!(this instanceof we.Event)) return new we.Event(e, t);
    e && e.type ? (this.originalEvent = e, this.type = e.type, this.isDefaultPrevented = e.defaultPrevented || void 0 === e.defaultPrevented && !1 === e.returnValue ? T : k, this.target = e.target && 3 === e.target.nodeType ? e.target.parentNode : e.target, this.currentTarget = e.currentTarget, this.relatedTarget = e.relatedTarget)  : this.type = e,
    t && we.extend(this, t),
    this.timeStamp = e && e.timeStamp || Date.now(),
    this[we.expando] = !0
  },
  we.Event.prototype = {
    constructor: we.Event,
    isDefaultPrevented: k,
    isPropagationStopped: k,
    isImmediatePropagationStopped: k,
    isSimulated: !1,
    preventDefault: function () {
      var e = this.originalEvent;
      this.isDefaultPrevented = T,
      e && !this.isSimulated && e.preventDefault()
    },
    stopPropagation: function () {
      var e = this.originalEvent;
      this.isPropagationStopped = T,
      e && !this.isSimulated && e.stopPropagation()
    },
    stopImmediatePropagation: function () {
      var e = this.originalEvent;
      this.isImmediatePropagationStopped = T,
      e && !this.isSimulated && e.stopImmediatePropagation(),
      this.stopPropagation()
    }
  },
  we.each({
    altKey: !0,
    bubbles: !0,
    cancelable: !0,
    changedTouches: !0,
    ctrlKey: !0,
    detail: !0,
    eventPhase: !0,
    metaKey: !0,
    pageX: !0,
    pageY: !0,
    shiftKey: !0,
    view: !0,
    char: !0,
    charCode: !0,
    key: !0,
    keyCode: !0,
    button: !0,
    buttons: !0,
    clientX: !0,
    clientY: !0,
    offsetX: !0,
    offsetY: !0,
    pointerId: !0,
    pointerType: !0,
    screenX: !0,
    screenY: !0,
    targetTouches: !0,
    toElement: !0,
    touches: !0,
    which: function (e) {
      var t = e.button;
      return null == e.which && tt.test(e.type) ? null != e.charCode ? e.charCode : e.keyCode : !e.which && void 0 !== t && nt.test(e.type) ? 1 & t ? 1 : 2 & t ? 3 : 4 & t ? 2 : 0 : e.which
    }
  }, we.event.addProp),
  we.each({
    mouseenter: 'mouseover',
    mouseleave: 'mouseout',
    pointerenter: 'pointerover',
    pointerleave: 'pointerout'
  }, function (e, t) {
    we.event.special[e] = {
      delegateType: t,
      bindType: t,
      handle: function (e) {
        var n,
        r = this,
        o = e.relatedTarget,
        i = e.handleObj;
        return o && (o === r || we.contains(r, o)) || (e.type = i.origType, n = i.handler.apply(this, arguments), e.type = t),
        n
      }
    }
  }),
  we.fn.extend({
    on: function (e, t, n, r) {
      return D(this, e, t, n, r)
    },
    one: function (e, t, n, r) {
      return D(this, e, t, n, r, 1)
    },
    off: function (e, t, n) {
      var r,
      o;
      if (e && e.preventDefault && e.handleObj) return r = e.handleObj,
      we(e.delegateTarget).off(r.namespace ? r.origType + '.' + r.namespace : r.origType, r.selector, r.handler),
      this;
      if ('object' == typeof e) {
        for (o in e) this.off(o, t, e[o]);
        return this
      }
      return !1 !== t && 'function' != typeof t || (n = t, t = void 0),
      !1 === n && (n = k),
      this.each(function () {
        we.event.remove(this, e, n, t)
      })
    }
  });
  var ot = /<(?!area|br|col|embed|hr|img|input|link|meta|param)(([a-z][^\/\0>\x20\t\r\n\f]*)[^>]*)\/>/gi,
  it = /<script|<style|<link/i,
  at = /checked\s*(?:[^=]|=\s*.checked.)/i,
  st = /^\s*<!(?:\[CDATA\[|--)|(?:\]\]|--)>\s*$/g;
  we.extend({
    htmlPrefilter: function (e) {
      return e.replace(ot, '<$1></$2>')
    },
    clone: function (e, t, n) {
      var r,
      o,
      i,
      a,
      s = e.cloneNode(!0),
      l = we.contains(e.ownerDocument, e);
      if (!(ve.noCloneChecked || 1 !== e.nodeType && 11 !== e.nodeType || we.isXMLDoc(e))) for (a = w(s), r = 0, o = (i = w(e)).length; r < o; r++) B(i[r], a[r]);
      if (t) if (n) for (i = i || w(e), a = a || w(s), r = 0, o = i.length; r < o; r++) j(i[r], a[r]);
       else j(e, s);
      return (a = w(s, 'script')).length > 0 && S(a, !l && w(e, 'script')),
      s
    },
    cleanData: function (e) {
      for (var t, n, r, o = we.event.special, i = 0; void 0 !== (n = e[i]); i++) if (He(n)) {
        if (t = n[qe.expando]) {
          if (t.events) for (r in t.events) o[r] ? we.event.remove(n, r)  : we.removeEvent(n, r, t.handle);
          n[qe.expando] = void 0
        }
        n[Re.expando] && (n[Re.expando] = void 0)
      }
    }
  }),
  we.fn.extend({
    detach: function (e) {
      return L(this, e, !0)
    },
    remove: function (e) {
      return L(this, e)
    },
    text: function (e) {
      return Ne(this, function (e) {
        return void 0 === e ? we.text(this)  : this.empty().each(function () {
          1 !== this.nodeType && 11 !== this.nodeType && 9 !== this.nodeType || (this.textContent = e)
        })
      }, null, e, arguments.length)
    },
    append: function () {
      return O(this, arguments, function (e) {
        1 !== this.nodeType && 11 !== this.nodeType && 9 !== this.nodeType || E(this, e).appendChild(e)
      })
    },
    prepend: function () {
      return O(this, arguments, function (e) {
        if (1 === this.nodeType || 11 === this.nodeType || 9 === this.nodeType) {
          var t = E(this, e);
          t.insertBefore(e, t.firstChild)
        }
      })
    },
    before: function () {
      return O(this, arguments, function (e) {
        this.parentNode && this.parentNode.insertBefore(e, this)
      })
    },
    after: function () {
      return O(this, arguments, function (e) {
        this.parentNode && this.parentNode.insertBefore(e, this.nextSibling)
      })
    },
    empty: function () {
      for (var e, t = 0; null != (e = this[t]); t++) 1 === e.nodeType && (we.cleanData(w(e, !1)), e.textContent = '');
      return this
    },
    clone: function (e, t) {
      return e = null != e && e,
      t = null == t ? e : t,
      this.map(function () {
        return we.clone(this, e, t)
      })
    },
    html: function (e) {
      return Ne(this, function (e) {
        var t = this[0] || {
        },
        n = 0,
        r = this.length;
        if (void 0 === e && 1 === t.nodeType) return t.innerHTML;
        if ('string' == typeof e && !it.test(e) && !Je[(Qe.exec(e) || [
          '',
          ''
        ]) [1].toLowerCase()]) {
          e = we.htmlPrefilter(e);
          try {
            for (; n < r; n++) 1 === (t = this[n] || {
            }).nodeType && (we.cleanData(w(t, !1)), t.innerHTML = e);
            t = 0
          } catch (e) {
          }
        }
        t && this.empty().append(e)
      }, null, e, arguments.length)
    },
    replaceWith: function () {
      var e = [
      ];
      return O(this, arguments, function (t) {
        var n = this.parentNode;
        we.inArray(this, e) < 0 && (we.cleanData(w(this)), n && n.replaceChild(t, this))
      }, e)
    }
  }),
  we.each({
    appendTo: 'append',
    prependTo: 'prepend',
    insertBefore: 'before',
    insertAfter: 'after',
    replaceAll: 'replaceWith'
  }, function (e, t) {
    we.fn[e] = function (e) {
      for (var n, r = [
      ], o = we(e), i = o.length - 1, a = 0; a <= i; a++) n = a === i ? this : this.clone(!0),
      we(o[a]) [t](n),
      ue.apply(r, n.get());
      return this.pushStack(r)
    }
  });
  var lt = new RegExp('^(' + Fe + ')(?!px)[a-z%]+$', 'i'),
  ct = function (t) {
    var n = t.ownerDocument.defaultView;
    return n && n.opener || (n = e),
    n.getComputedStyle(t)
  },
  ut = new RegExp(Xe.join('|'), 'i');
  !function () {
    function t() {
      if (c) {
        l.style.cssText = 'position:absolute;left:-11111px;width:60px;margin-top:1px;padding:0;border:0',
        c.style.cssText = 'position:relative;display:block;box-sizing:border-box;overflow:scroll;margin:auto;border:1px;padding:1px;width:60%;top:1%',
        et.appendChild(l).appendChild(c);
        var t = e.getComputedStyle(c);
        r = '1%' !== t.top,
        s = 12 === n(t.marginLeft),
        c.style.right = '60%',
        a = 36 === n(t.right),
        o = 36 === n(t.width),
        c.style.position = 'absolute',
        i = 36 === c.offsetWidth || 'absolute',
        et.removeChild(l),
        c = null
      }
    }
    function n(e) {
      return Math.round(parseFloat(e))
    }
    var r,
    o,
    i,
    a,
    s,
    l = ae.createElement('div'),
    c = ae.createElement('div');
    c.style && (c.style.backgroundClip = 'content-box', c.cloneNode(!0).style.backgroundClip = '', ve.clearCloneStyle = 'content-box' === c.style.backgroundClip, we.extend(ve, {
      boxSizingReliable: function () {
        return t(),
        o
      },
      pixelBoxStyles: function () {
        return t(),
        a
      },
      pixelPosition: function () {
        return t(),
        r
      },
      reliableMarginLeft: function () {
        return t(),
        s
      },
      scrollboxSize: function () {
        return t(),
        i
      }
    }))
  }();
  var dt = /^(none|table(?!-c[ea]).+)/,
  ft = /^--/,
  pt = {
    position: 'absolute',
    visibility: 'hidden',
    display: 'block'
  },
  ht = {
    letterSpacing: '0',
    fontWeight: '400'
  },
  mt = [
    'Webkit',
    'Moz',
    'ms'
  ],
  gt = ae.createElement('div').style;
  we.extend({
    cssHooks: {
      opacity: {
        get: function (e, t) {
          if (t) {
            var n = N(e, 'opacity');
            return '' === n ? '1' : n
          }
        }
      }
    },
    cssNumber: {
      animationIterationCount: !0,
      columnCount: !0,
      fillOpacity: !0,
      flexGrow: !0,
      flexShrink: !0,
      fontWeight: !0,
      lineHeight: !0,
      opacity: !0,
      order: !0,
      orphans: !0,
      widows: !0,
      zIndex: !0,
      zoom: !0
    },
    cssProps: {
    },
    style: function (e, t, n, r) {
      if (e && 3 !== e.nodeType && 8 !== e.nodeType && e.style) {
        var o,
        i,
        a,
        s = h(t),
        l = ft.test(t),
        c = e.style;
        if (l || (t = H(s)), a = we.cssHooks[t] || we.cssHooks[s], void 0 === n) return a && 'get' in a && void 0 !== (o = a.get(e, !1, r)) ? o : c[t];
        'string' == (i = typeof n) && (o = $e.exec(n)) && o[1] && (n = y(e, t, o), i = 'number'),
        null != n && n === n && ('number' === i && (n += o && o[3] || (we.cssNumber[s] ? '' : 'px')), ve.clearCloneStyle || '' !== n || 0 !== t.indexOf('background') || (c[t] = 'inherit'), a && 'set' in a && void 0 === (n = a.set(e, n, r)) || (l ? c.setProperty(t, n)  : c[t] = n))
      }
    },
    css: function (e, t, n, r) {
      var o,
      i,
      a,
      s = h(t);
      return ft.test(t) || (t = H(s)),
      (a = we.cssHooks[t] || we.cssHooks[s]) && 'get' in a && (o = a.get(e, !0, n)),
      void 0 === o && (o = N(e, t, r)),
      'normal' === o && t in ht && (o = ht[t]),
      '' === n || n ? (i = parseFloat(o), !0 === n || isFinite(i) ? i || 0 : o)  : o
    }
  }),
  we.each(['height',
  'width'], function (e, t) {
    we.cssHooks[t] = {
      get: function (e, n, r) {
        if (n) return !dt.test(we.css(e, 'display')) || e.getClientRects().length && e.getBoundingClientRect().width ? W(e, t, r)  : Ye(e, pt, function () {
          return W(e, t, r)
        })
      },
      set: function (e, n, r) {
        var o,
        i = ct(e),
        a = 'border-box' === we.css(e, 'boxSizing', !1, i),
        s = r && R(e, t, r, a, i);
        return a && ve.scrollboxSize() === i.position && (s -= Math.ceil(e['offset' + t[0].toUpperCase() + t.slice(1)] - parseFloat(i[t]) - R(e, t, 'border', !1, i) - 0.5)),
        s && (o = $e.exec(n)) && 'px' !== (o[3] || 'px') && (e.style[t] = n, n = we.css(e, t)),
        q(e, n, s)
      }
    }
  }),
  we.cssHooks.marginLeft = I(ve.reliableMarginLeft, function (e, t) {
    if (t) return (parseFloat(N(e, 'marginLeft')) || e.getBoundingClientRect().left - Ye(e, {
      marginLeft: 0
    }, function () {
      return e.getBoundingClientRect().left
    })) + 'px'
  }),
  we.each({
    margin: '',
    padding: '',
    border: 'Width'
  }, function (e, t) {
    we.cssHooks[e + t] = {
      expand: function (n) {
        for (var r = 0, o = {
        }, i = 'string' == typeof n ? n.split(' ')  : [
          n
        ]; r < 4; r++) o[e + Xe[r] + t] = i[r] || i[r - 2] || i[0];
        return o
      }
    },
    'margin' !== e && (we.cssHooks[e + t].set = q)
  }),
  we.fn.extend({
    css: function (e, t) {
      return Ne(this, function (e, t, n) {
        var r,
        o,
        i = {
        },
        a = 0;
        if (Array.isArray(t)) {
          for (r = ct(e), o = t.length; a < o; a++) i[t[a]] = we.css(e, t[a], !1, r);
          return i
        }
        return void 0 !== n ? we.style(e, t, n)  : we.css(e, t)
      }, e, t, arguments.length > 1)
    }
  }),
  we.Tween = z,
  z.prototype = {
    constructor: z,
    init: function (e, t, n, r, o, i) {
      this.elem = e,
      this.prop = n,
      this.easing = o || we.easing._default,
      this.options = t,
      this.start = this.now = this.cur(),
      this.end = r,
      this.unit = i || (we.cssNumber[n] ? '' : 'px')
    },
    cur: function () {
      var e = z.propHooks[this.prop];
      return e && e.get ? e.get(this)  : z.propHooks._default.get(this)
    },
    run: function (e) {
      var t,
      n = z.propHooks[this.prop];
      return this.options.duration ? this.pos = t = we.easing[this.easing](e, this.options.duration * e, 0, 1, this.options.duration)  : this.pos = t = e,
      this.now = (this.end - this.start) * t + this.start,
      this.options.step && this.options.step.call(this.elem, this.now, this),
      n && n.set ? n.set(this)  : z.propHooks._default.set(this),
      this
    }
  },
  z.prototype.init.prototype = z.prototype,
  z.propHooks = {
    _default: {
      get: function (e) {
        var t;
        return 1 !== e.elem.nodeType || null != e.elem[e.prop] && null == e.elem.style[e.prop] ? e.elem[e.prop] : (t = we.css(e.elem, e.prop, '')) && 'auto' !== t ? t : 0
      },
      set: function (e) {
        we.fx.step[e.prop] ? we.fx.step[e.prop](e)  : 1 !== e.elem.nodeType || null == e.elem.style[we.cssProps[e.prop]] && !we.cssHooks[e.prop] ? e.elem[e.prop] = e.now : we.style(e.elem, e.prop, e.now + e.unit)
      }
    }
  },
  z.propHooks.scrollTop = z.propHooks.scrollLeft = {
    set: function (e) {
      e.elem.nodeType && e.elem.parentNode && (e.elem[e.prop] = e.now)
    }
  },
  we.easing = {
    linear: function (e) {
      return e
    },
    swing: function (e) {
      return 0.5 - Math.cos(e * Math.PI) / 2
    },
    _default: 'swing'
  },
  we.fx = z.prototype.init,
  we.fx.step = {
  };
  var vt,
  yt,
  xt = /^(?:toggle|show|hide)$/,
  bt = /queueHooks$/;
  we.Animation = we.extend(G, {
    tweeners: {
      '*': [
        function (e, t) {
          var n = this.createTween(e, t);
          return y(n.elem, e, $e.exec(t), n),
          n
        }
      ]
    },
    tweener: function (e, t) {
      ye(e) ? (t = e, e = [
        '*'
      ])  : e = e.match(Be);
      for (var n, r = 0, o = e.length; r < o; r++) n = e[r],
      G.tweeners[n] = G.tweeners[n] || [
      ],
      G.tweeners[n].unshift(t)
    },
    prefilters: [
      Y
    ],
    prefilter: function (e, t) {
      t ? G.prefilters.unshift(e)  : G.prefilters.push(e)
    }
  }),
  we.speed = function (e, t, n) {
    var r = e && 'object' == typeof e ? we.extend({
    }, e)  : {
      complete: n || !n && t || ye(e) && e,
      duration: e,
      easing: n && t || t && !ye(t) && t
    };
    return we.fx.off ? r.duration = 0 : 'number' != typeof r.duration && (r.duration in we.fx.speeds ? r.duration = we.fx.speeds[r.duration] : r.duration = we.fx.speeds._default),
    null != r.queue && !0 !== r.queue || (r.queue = 'fx'),
    r.old = r.complete,
    r.complete = function () {
      ye(r.old) && r.old.call(this),
      r.queue && we.dequeue(this, r.queue)
    },
    r
  },
  we.fn.extend({
    fadeTo: function (e, t, n, r) {
      return this.filter(Ue).css('opacity', 0).show().end().animate({
        opacity: t
      }, e, n, r)
    },
    animate: function (e, t, n, r) {
      var o = we.isEmptyObject(e),
      i = we.speed(t, n, r),
      a = function () {
        var t = G(this, we.extend({
        }, e), i);
        (o || qe.get(this, 'finish')) && t.stop(!0)
      };
      return a.finish = a,
      o || !1 === i.queue ? this.each(a)  : this.queue(i.queue, a)
    },
    stop: function (e, t, n) {
      var r = function (e) {
        var t = e.stop;
        delete e.stop,
        t(n)
      };
      return 'string' != typeof e && (n = t, t = e, e = void 0),
      t && !1 !== e && this.queue(e || 'fx', [
      ]),
      this.each(function () {
        var t = !0,
        o = null != e && e + 'queueHooks',
        i = we.timers,
        a = qe.get(this);
        if (o) a[o] && a[o].stop && r(a[o]);
         else for (o in a) a[o] && a[o].stop && bt.test(o) && r(a[o]);
        for (o = i.length; o--; ) i[o].elem !== this || null != e && i[o].queue !== e || (i[o].anim.stop(n), t = !1, i.splice(o, 1));
        !t && n || we.dequeue(this, e)
      })
    },
    finish: function (e) {
      return !1 !== e && (e = e || 'fx'),
      this.each(function () {
        var t,
        n = qe.get(this),
        r = n[e + 'queue'],
        o = n[e + 'queueHooks'],
        i = we.timers,
        a = r ? r.length : 0;
        for (n.finish = !0, we.queue(this, e, [
        ]), o && o.stop && o.stop.call(this, !0), t = i.length; t--; ) i[t].elem === this && i[t].queue === e && (i[t].anim.stop(!0), i.splice(t, 1));
        for (t = 0; t < a; t++) r[t] && r[t].finish && r[t].finish.call(this);
        delete n.finish
      })
    }
  }),
  we.each(['toggle',
  'show',
  'hide'], function (e, t) {
    var n = we.fn[t];
    we.fn[t] = function (e, r, o) {
      return null == e || 'boolean' == typeof e ? n.apply(this, arguments)  : this.animate(X(t, !0), e, r, o)
    }
  }),
  we.each({
    slideDown: X('show'),
    slideUp: X('hide'),
    slideToggle: X('toggle'),
    fadeIn: {
      opacity: 'show'
    },
    fadeOut: {
      opacity: 'hide'
    },
    fadeToggle: {
      opacity: 'toggle'
    }
  }, function (e, t) {
    we.fn[e] = function (e, n, r) {
      return this.animate(t, e, n, r)
    }
  }),
  we.timers = [
  ],
  we.fx.tick = function () {
    var e,
    t = 0,
    n = we.timers;
    for (vt = Date.now(); t < n.length; t++) (e = n[t]) () || n[t] !== e || n.splice(t--, 1);
    n.length || we.fx.stop(),
    vt = void 0
  },
  we.fx.timer = function (e) {
    we.timers.push(e),
    we.fx.start()
  },
  we.fx.interval = 13,
  we.fx.start = function () {
    yt || (yt = !0, F())
  },
  we.fx.stop = function () {
    yt = null
  },
  we.fx.speeds = {
    slow: 600,
    fast: 200,
    _default: 400
  },
  we.fn.delay = function (t, n) {
    return t = we.fx ? we.fx.speeds[t] || t : t,
    n = n || 'fx',
    this.queue(n, function (n, r) {
      var o = e.setTimeout(n, t);
      r.stop = function () {
        e.clearTimeout(o)
      }
    })
  },
  function () {
    var e = ae.createElement('input'),
    t = ae.createElement('select').appendChild(ae.createElement('option'));
    e.type = 'checkbox',
    ve.checkOn = '' !== e.value,
    ve.optSelected = t.selected,
    (e = ae.createElement('input')).value = 't',
    e.type = 'radio',
    ve.radioValue = 't' === e.value
  }();
  var wt,
  St = we.expr.attrHandle;
  we.fn.extend({
    attr: function (e, t) {
      return Ne(this, we.attr, e, t, arguments.length > 1)
    },
    removeAttr: function (e) {
      return this.each(function () {
        we.removeAttr(this, e)
      })
    }
  }),
  we.extend({
    attr: function (e, t, n) {
      var r,
      o,
      i = e.nodeType;
      if (3 !== i && 8 !== i && 2 !== i) return void 0 === e.getAttribute ? we.prop(e, t, n)  : (1 === i && we.isXMLDoc(e) || (o = we.attrHooks[t.toLowerCase()] || (we.expr.match.bool.test(t) ? wt : void 0)), void 0 !== n ? null === n ? void we.removeAttr(e, t)  : o && 'set' in o && void 0 !== (r = o.set(e, n, t)) ? r : (e.setAttribute(t, n + ''), n)  : o && 'get' in o && null !== (r = o.get(e, t)) ? r : null == (r = we.find.attr(e, t)) ? void 0 : r)
    },
    attrHooks: {
      type: {
        set: function (e, t) {
          if (!ve.radioValue && 'radio' === t && i(e, 'input')) {
            var n = e.value;
            return e.setAttribute('type', t),
            n && (e.value = n),
            t
          }
        }
      }
    },
    removeAttr: function (e, t) {
      var n,
      r = 0,
      o = t && t.match(Be);
      if (o && 1 === e.nodeType) for (; n = o[r++]; ) e.removeAttribute(n)
    }
  }),
  wt = {
    set: function (e, t, n) {
      return !1 === t ? we.removeAttr(e, n)  : e.setAttribute(n, n),
      n
    }
  },
  we.each(we.expr.match.bool.source.match(/\w+/g), function (e, t) {
    var n = St[t] || we.find.attr;
    St[t] = function (e, t, r) {
      var o,
      i,
      a = t.toLowerCase();
      return r || (i = St[a], St[a] = o, o = null != n(e, t, r) ? a : null, St[a] = i),
      o
    }
  });
  var Ct = /^(?:input|select|textarea|button)$/i,
  Tt = /^(?:a|area)$/i;
  we.fn.extend({
    prop: function (e, t) {
      return Ne(this, we.prop, e, t, arguments.length > 1)
    },
    removeProp: function (e) {
      return this.each(function () {
        delete this[we.propFix[e] || e]
      })
    }
  }),
  we.extend({
    prop: function (e, t, n) {
      var r,
      o,
      i = e.nodeType;
      if (3 !== i && 8 !== i && 2 !== i) return 1 === i && we.isXMLDoc(e) || (t = we.propFix[t] || t, o = we.propHooks[t]),
      void 0 !== n ? o && 'set' in o && void 0 !== (r = o.set(e, n, t)) ? r : e[t] = n : o && 'get' in o && null !== (r = o.get(e, t)) ? r : e[t]
    },
    propHooks: {
      tabIndex: {
        get: function (e) {
          var t = we.find.attr(e, 'tabindex');
          return t ? parseInt(t, 10)  : Ct.test(e.nodeName) || Tt.test(e.nodeName) && e.href ? 0 : - 1
        }
      }
    },
    propFix: {
      for : 'htmlFor',
      class : 'className'
    }
  }),
  ve.optSelected || (we.propHooks.selected = {
    get: function (e) {
      var t = e.parentNode;
      return t && t.parentNode && t.parentNode.selectedIndex,
      null
    },
    set: function (e) {
      var t = e.parentNode;
      t && (t.selectedIndex, t.parentNode && t.parentNode.selectedIndex)
    }
  }),
  we.each(['tabIndex',
  'readOnly',
  'maxLength',
  'cellSpacing',
  'cellPadding',
  'rowSpan',
  'colSpan',
  'useMap',
  'frameBorder',
  'contentEditable'], function () {
    we.propFix[this.toLowerCase()] = this
  }),
  we.fn.extend({
    addClass: function (e) {
      var t,
      n,
      r,
      o,
      i,
      a,
      s,
      l = 0;
      if (ye(e)) return this.each(function (t) {
        we(this).addClass(e.call(this, t, K(this)))
      });
      if ((t = J(e)).length) for (; n = this[l++]; ) if (o = K(n), r = 1 === n.nodeType && ' ' + Q(o) + ' ') {
        for (a = 0; i = t[a++]; ) r.indexOf(' ' + i + ' ') < 0 && (r += i + ' ');
        o !== (s = Q(r)) && n.setAttribute('class', s)
      }
      return this
    },
    removeClass: function (e) {
      var t,
      n,
      r,
      o,
      i,
      a,
      s,
      l = 0;
      if (ye(e)) return this.each(function (t) {
        we(this).removeClass(e.call(this, t, K(this)))
      });
      if (!arguments.length) return this.attr('class', '');
      if ((t = J(e)).length) for (; n = this[l++]; ) if (o = K(n), r = 1 === n.nodeType && ' ' + Q(o) + ' ') {
        for (a = 0; i = t[a++]; ) for (; r.indexOf(' ' + i + ' ') > - 1; ) r = r.replace(' ' + i + ' ', ' ');
        o !== (s = Q(r)) && n.setAttribute('class', s)
      }
      return this
    },
    toggleClass: function (e, t) {
      var n = typeof e,
      r = 'string' === n || Array.isArray(e);
      return 'boolean' == typeof t && r ? t ? this.addClass(e)  : this.removeClass(e)  : ye(e) ? this.each(function (n) {
        we(this).toggleClass(e.call(this, n, K(this), t), t)
      })  : this.each(function () {
        var t,
        o,
        i,
        a;
        if (r) for (o = 0, i = we(this), a = J(e); t = a[o++]; ) i.hasClass(t) ? i.removeClass(t)  : i.addClass(t);
         else void 0 !== e && 'boolean' !== n || ((t = K(this)) && qe.set(this, '__className__', t), this.setAttribute && this.setAttribute('class', t || !1 === e ? '' : qe.get(this, '__className__') || ''))
      })
    },
    hasClass: function (e) {
      var t,
      n,
      r = 0;
      for (t = ' ' + e + ' '; n = this[r++]; ) if (1 === n.nodeType && (' ' + Q(K(n)) + ' ').indexOf(t) > - 1) return !0;
      return !1
    }
  });
  var kt = /\r/g;
  we.fn.extend({
    val: function (e) {
      var t,
      n,
      r,
      o = this[0];
      return arguments.length ? (r = ye(e), this.each(function (n) {
        var o;
        1 === this.nodeType && (null == (o = r ? e.call(this, n, we(this).val())  : e) ? o = '' : 'number' == typeof o ? o += '' : Array.isArray(o) && (o = we.map(o, function (e) {
          return null == e ? '' : e + ''
        })), (t = we.valHooks[this.type] || we.valHooks[this.nodeName.toLowerCase()]) && 'set' in t && void 0 !== t.set(this, o, 'value') || (this.value = o))
      }))  : o ? (t = we.valHooks[o.type] || we.valHooks[o.nodeName.toLowerCase()]) && 'get' in t && void 0 !== (n = t.get(o, 'value')) ? n : 'string' == typeof (n = o.value) ? n.replace(kt, '')  : null == n ? '' : n : void 0
    }
  }),
  we.extend({
    valHooks: {
      option: {
        get: function (e) {
          var t = we.find.attr(e, 'value');
          return null != t ? t : Q(we.text(e))
        }
      },
      select: {
        get: function (e) {
          var t,
          n,
          r,
          o = e.options,
          a = e.selectedIndex,
          s = 'select-one' === e.type,
          l = s ? null : [
          ],
          c = s ? a + 1 : o.length;
          for (r = a < 0 ? c : s ? a : 0; r < c; r++) if (((n = o[r]).selected || r === a) && !n.disabled && (!n.parentNode.disabled || !i(n.parentNode, 'optgroup'))) {
            if (t = we(n).val(), s) return t;
            l.push(t)
          }
          return l
        },
        set: function (e, t) {
          for (var n, r, o = e.options, i = we.makeArray(t), a = o.length; a--; ) ((r = o[a]).selected = we.inArray(we.valHooks.option.get(r), i) > - 1) && (n = !0);
          return n || (e.selectedIndex = - 1),
          i
        }
      }
    }
  }),
  we.each(['radio',
  'checkbox'], function () {
    we.valHooks[this] = {
      set: function (e, t) {
        if (Array.isArray(t)) return e.checked = we.inArray(we(e).val(), t) > - 1
      }
    },
    ve.checkOn || (we.valHooks[this].get = function (e) {
      return null === e.getAttribute('value') ? 'on' : e.value
    })
  }),
  ve.focusin = 'onfocusin' in e;
  var _t = /^(?:focusinfocus|focusoutblur)$/,
  Dt = function (e) {
    e.stopPropagation()
  };
  we.extend(we.event, {
    trigger: function (t, n, r, o) {
      var i,
      a,
      s,
      l,
      c,
      u,
      d,
      f,
      p = [
        r || ae
      ],
      h = he.call(t, 'type') ? t.type : t,
      m = he.call(t, 'namespace') ? t.namespace.split('.')  : [
      ];
      if (a = f = s = r = r || ae, 3 !== r.nodeType && 8 !== r.nodeType && !_t.test(h + we.event.triggered) && (h.indexOf('.') > - 1 && (h = (m = h.split('.')).shift(), m.sort()), c = h.indexOf(':') < 0 && 'on' + h, t = t[we.expando] ? t : new we.Event(h, 'object' == typeof t && t), t.isTrigger = o ? 2 : 3, t.namespace = m.join('.'), t.rnamespace = t.namespace ? new RegExp('(^|\\.)' + m.join('\\.(?:.*\\.|)') + '(\\.|$)')  : null, t.result = void 0, t.target || (t.target = r), n = null == n ? [
        t
      ] : we.makeArray(n, [
        t
      ]), d = we.event.special[h] || {
      }, o || !d.trigger || !1 !== d.trigger.apply(r, n))) {
        if (!o && !d.noBubble && !xe(r)) {
          for (l = d.delegateType || h, _t.test(l + h) || (a = a.parentNode); a; a = a.parentNode) p.push(a),
          s = a;
          s === (r.ownerDocument || ae) && p.push(s.defaultView || s.parentWindow || e)
        }
        for (i = 0; (a = p[i++]) && !t.isPropagationStopped(); ) f = a,
        t.type = i > 1 ? l : d.bindType || h,
        (u = (qe.get(a, 'events') || {
        }) [t.type] && qe.get(a, 'handle')) && u.apply(a, n),
        (u = c && a[c]) && u.apply && He(a) && (t.result = u.apply(a, n), !1 === t.result && t.preventDefault());
        return t.type = h,
        o || t.isDefaultPrevented() || d._default && !1 !== d._default.apply(p.pop(), n) || !He(r) || c && ye(r[h]) && !xe(r) && ((s = r[c]) && (r[c] = null), we.event.triggered = h, t.isPropagationStopped() && f.addEventListener(h, Dt), r[h](), t.isPropagationStopped() && f.removeEventListener(h, Dt), we.event.triggered = void 0, s && (r[c] = s)),
        t.result
      }
    },
    simulate: function (e, t, n) {
      var r = we.extend(new we.Event, n, {
        type: e,
        isSimulated: !0
      });
      we.event.trigger(r, null, t)
    }
  }),
  we.fn.extend({
    trigger: function (e, t) {
      return this.each(function () {
        we.event.trigger(e, t, this)
      })
    },
    triggerHandler: function (e, t) {
      var n = this[0];
      if (n) return we.event.trigger(e, t, n, !0)
    }
  }),
  ve.focusin || we.each({
    focus: 'focusin',
    blur: 'focusout'
  }, function (e, t) {
    var n = function (e) {
      we.event.simulate(t, e.target, we.event.fix(e))
    };
    we.event.special[t] = {
      setup: function () {
        var r = this.ownerDocument || this,
        o = qe.access(r, t);
        o || r.addEventListener(e, n, !0),
        qe.access(r, t, (o || 0) + 1)
      },
      teardown: function () {
        var r = this.ownerDocument || this,
        o = qe.access(r, t) - 1;
        o ? qe.access(r, t, o)  : (r.removeEventListener(e, n, !0), qe.remove(r, t))
      }
    }
  });
  var Et = e.location,
  Mt = Date.now(),
  At = /\?/;
  we.parseXML = function (t) {
    var n;
    if (!t || 'string' != typeof t) return null;
    try {
      n = (new e.DOMParser).parseFromString(t, 'text/xml')
    } catch (e) {
      n = void 0
    }
    return n && !n.getElementsByTagName('parsererror').length || we.error('Invalid XML: ' + t),
    n
  };
  var jt = /\[\]$/,
  Bt = /\r?\n/g,
  Ot = /^(?:submit|button|image|reset|file)$/i,
  Lt = /^(?:input|select|textarea|keygen)/i;
  we.param = function (e, t) {
    var n,
    r = [
    ],
    o = function (e, t) {
      var n = ye(t) ? t()  : t;
      r[r.length] = encodeURIComponent(e) + '=' + encodeURIComponent(null == n ? '' : n)
    };
    if (Array.isArray(e) || e.jquery && !we.isPlainObject(e)) we.each(e, function () {
      o(this.name, this.value)
    });
     else for (n in e) Z(n, e[n], t, o);
    return r.join('&')
  },
  we.fn.extend({
    serialize: function () {
      return we.param(this.serializeArray())
    },
    serializeArray: function () {
      return this.map(function () {
        var e = we.prop(this, 'elements');
        return e ? we.makeArray(e)  : this
      }).filter(function () {
        var e = this.type;
        return this.name && !we(this).is(':disabled') && Lt.test(this.nodeName) && !Ot.test(e) && (this.checked || !Ge.test(e))
      }).map(function (e, t) {
        var n = we(this).val();
        return null == n ? null : Array.isArray(n) ? we.map(n, function (e) {
          return {
            name: t.name,
            value: e.replace(Bt, '\r\n')
          }
        })  : {
          name: t.name,
          value: n.replace(Bt, '\r\n')
        }
      }).get()
    }
  });
  var Nt = /%20/g,
  It = /#.*$/,
  Pt = /([?&])_=[^&]*/,
  Ht = /^(.*?):[ \t]*([^\r\n]*)$/gm,
  qt = /^(?:about|app|app-storage|.+-extension|file|res|widget):$/,
  Rt = /^(?:GET|HEAD)$/,
  Wt = /^\/\//,
  zt = {
  },
  Ft = {
  },
  $t = '*/'.concat('*'),
  Xt = ae.createElement('a');
  Xt.href = Et.href,
  we.extend({
    active: 0,
    lastModified: {
    },
    etag: {
    },
    ajaxSettings: {
      url: Et.href,
      type: 'GET',
      isLocal: qt.test(Et.protocol),
      global: !0,
      processData: !0,
      async: !0,
      contentType: 'application/x-www-form-urlencoded; charset=UTF-8',
      accepts: {
        '*': $t,
        text: 'text/plain',
        html: 'text/html',
        xml: 'application/xml, text/xml',
        json: 'application/json, text/javascript'
      },
      contents: {
        xml: /\bxml\b/,
        html: /\bhtml/,
        json: /\bjson\b/
      },
      responseFields: {
        xml: 'responseXML',
        text: 'responseText',
        json: 'responseJSON'
      },
      converters: {
        '* text': String,
        'text html': !0,
        'text json': JSON.parse,
        'text xml': we.parseXML
      },
      flatOptions: {
        url: !0,
        context: !0
      }
    },
    ajaxSetup: function (e, t) {
      return t ? ne(ne(e, we.ajaxSettings), t)  : ne(we.ajaxSettings, e)
    },
    ajaxPrefilter: ee(zt),
    ajaxTransport: ee(Ft),
    ajax: function (t, n) {
      function r(t, n, r, s) {
        var c,
        f,
        p,
        b,
        w,
        S = n;
        u || (u = !0, l && e.clearTimeout(l), o = void 0, a = s || '', C.readyState = t > 0 ? 4 : 0, c = t >= 200 && t < 300 || 304 === t, r && (b = re(h, C, r)), b = oe(h, b, C, c), c ? (h.ifModified && ((w = C.getResponseHeader('Last-Modified')) && (we.lastModified[i] = w), (w = C.getResponseHeader('etag')) && (we.etag[i] = w)), 204 === t || 'HEAD' === h.type ? S = 'nocontent' : 304 === t ? S = 'notmodified' : (S = b.state, f = b.data, c = !(p = b.error)))  : (p = S, !t && S || (S = 'error', t < 0 && (t = 0))), C.status = t, C.statusText = (n || S) + '', c ? v.resolveWith(m, [
          f,
          S,
          C
        ])  : v.rejectWith(m, [
          C,
          S,
          p
        ]), C.statusCode(x), x = void 0, d && g.trigger(c ? 'ajaxSuccess' : 'ajaxError', [
          C,
          h,
          c ? f : p
        ]), y.fireWith(m, [
          C,
          S
        ]), d && (g.trigger('ajaxComplete', [
          C,
          h
        ]), --we.active || we.event.trigger('ajaxStop')))
      }
      'object' == typeof t && (n = t, t = void 0),
      n = n || {
      };
      var o,
      i,
      a,
      s,
      l,
      c,
      u,
      d,
      f,
      p,
      h = we.ajaxSetup({
      }, n),
      m = h.context || h,
      g = h.context && (m.nodeType || m.jquery) ? we(m)  : we.event,
      v = we.Deferred(),
      y = we.Callbacks('once memory'),
      x = h.statusCode || {
      },
      b = {
      },
      w = {
      },
      S = 'canceled',
      C = {
        readyState: 0,
        getResponseHeader: function (e) {
          var t;
          if (u) {
            if (!s) for (s = {
            }; t = Ht.exec(a); ) s[t[1].toLowerCase()] = t[2];
            t = s[e.toLowerCase()]
          }
          return null == t ? null : t
        },
        getAllResponseHeaders: function () {
          return u ? a : null
        },
        setRequestHeader: function (e, t) {
          return null == u && (e = w[e.toLowerCase()] = w[e.toLowerCase()] || e, b[e] = t),
          this
        },
        overrideMimeType: function (e) {
          return null == u && (h.mimeType = e),
          this
        },
        statusCode: function (e) {
          var t;
          if (e) if (u) C.always(e[C.status]);
           else for (t in e) x[t] = [
            x[t],
            e[t]
          ];
          return this
        },
        abort: function (e) {
          var t = e || S;
          return o && o.abort(t),
          r(0, t),
          this
        }
      };
      if (v.promise(C), h.url = ((t || h.url || Et.href) + '').replace(Wt, Et.protocol + '//'), h.type = n.method || n.type || h.method || h.type, h.dataTypes = (h.dataType || '*').toLowerCase().match(Be) || [
        ''
      ], null == h.crossDomain) {
        c = ae.createElement('a');
        try {
          c.href = h.url,
          c.href = c.href,
          h.crossDomain = Xt.protocol + '//' + Xt.host != c.protocol + '//' + c.host
        } catch (e) {
          h.crossDomain = !0
        }
      }
      if (h.data && h.processData && 'string' != typeof h.data && (h.data = we.param(h.data, h.traditional)), te(zt, h, n, C), u) return C;
      (d = we.event && h.global) && 0 == we.active++ && we.event.trigger('ajaxStart'),
      h.type = h.type.toUpperCase(),
      h.hasContent = !Rt.test(h.type),
      i = h.url.replace(It, ''),
      h.hasContent ? h.data && h.processData && 0 === (h.contentType || '').indexOf('application/x-www-form-urlencoded') && (h.data = h.data.replace(Nt, '+'))  : (p = h.url.slice(i.length), h.data && (h.processData || 'string' == typeof h.data) && (i += (At.test(i) ? '&' : '?') + h.data, delete h.data), !1 === h.cache && (i = i.replace(Pt, '$1'), p = (At.test(i) ? '&' : '?') + '_=' + Mt++ + p), h.url = i + p),
      h.ifModified && (we.lastModified[i] && C.setRequestHeader('If-Modified-Since', we.lastModified[i]), we.etag[i] && C.setRequestHeader('If-None-Match', we.etag[i])),
      (h.data && h.hasContent && !1 !== h.contentType || n.contentType) && C.setRequestHeader('Content-Type', h.contentType),
      C.setRequestHeader('Accept', h.dataTypes[0] && h.accepts[h.dataTypes[0]] ? h.accepts[h.dataTypes[0]] + ('*' !== h.dataTypes[0] ? ', ' + $t + '; q=0.01' : '')  : h.accepts['*']);
      for (f in h.headers) C.setRequestHeader(f, h.headers[f]);
      if (h.beforeSend && (!1 === h.beforeSend.call(m, C, h) || u)) return C.abort();
      if (S = 'abort', y.add(h.complete), C.done(h.success), C.fail(h.error), o = te(Ft, h, n, C)) {
        if (C.readyState = 1, d && g.trigger('ajaxSend', [
          C,
          h
        ]), u) return C;
        h.async && h.timeout > 0 && (l = e.setTimeout(function () {
          C.abort('timeout')
        }, h.timeout));
        try {
          u = !1,
          o.send(b, r)
        } catch (e) {
          if (u) throw e;
          r( - 1, e)
        }
      } else r( - 1, 'No Transport');
      return C
    },
    getJSON: function (e, t, n) {
      return we.get(e, t, n, 'json')
    },
    getScript: function (e, t) {
      return we.get(e, void 0, t, 'script')
    }
  }),
  we.each(['get',
  'post'], function (e, t) {
    we[t] = function (e, n, r, o) {
      return ye(n) && (o = o || r, r = n, n = void 0),
      we.ajax(we.extend({
        url: e,
        type: t,
        dataType: o,
        data: n,
        success: r
      }, we.isPlainObject(e) && e))
    }
  }),
  we._evalUrl = function (e) {
    return we.ajax({
      url: e,
      type: 'GET',
      dataType: 'script',
      cache: !0,
      async: !1,
      global: !1,
      throws: !0
    })
  },
  we.fn.extend({
    wrapAll: function (e) {
      var t;
      return this[0] && (ye(e) && (e = e.call(this[0])), t = we(e, this[0].ownerDocument).eq(0).clone(!0), this[0].parentNode && t.insertBefore(this[0]), t.map(function () {
        for (var e = this; e.firstElementChild; ) e = e.firstElementChild;
        return e
      }).append(this)),
      this
    },
    wrapInner: function (e) {
      return ye(e) ? this.each(function (t) {
        we(this).wrapInner(e.call(this, t))
      })  : this.each(function () {
        var t = we(this),
        n = t.contents();
        n.length ? n.wrapAll(e)  : t.append(e)
      })
    },
    wrap: function (e) {
      var t = ye(e);
      return this.each(function (n) {
        we(this).wrapAll(t ? e.call(this, n)  : e)
      })
    },
    unwrap: function (e) {
      return this.parent(e).not('body').each(function () {
        we(this).replaceWith(this.childNodes)
      }),
      this
    }
  }),
  we.expr.pseudos.hidden = function (e) {
    return !we.expr.pseudos.visible(e)
  },
  we.expr.pseudos.visible = function (e) {
    return !!(e.offsetWidth || e.offsetHeight || e.getClientRects().length)
  },
  we.ajaxSettings.xhr = function () {
    try {
      return new e.XMLHttpRequest
    } catch (e) {
    }
  };
  var Ut = {
    0: 200,
    1223: 204
  },
  Yt = we.ajaxSettings.xhr();
  ve.cors = !!Yt && 'withCredentials' in Yt,
  ve.ajax = Yt = !!Yt,
  we.ajaxTransport(function (t) {
    var n,
    r;
    if (ve.cors || Yt && !t.crossDomain) return {
      send: function (o, i) {
        var a,
        s = t.xhr();
        if (s.open(t.type, t.url, t.async, t.username, t.password), t.xhrFields) for (a in t.xhrFields) s[a] = t.xhrFields[a];
        t.mimeType && s.overrideMimeType && s.overrideMimeType(t.mimeType),
        t.crossDomain || o['X-Requested-With'] || (o['X-Requested-With'] = 'XMLHttpRequest');
        for (a in o) s.setRequestHeader(a, o[a]);
        n = function (e) {
          return function () {
            n && (n = r = s.onload = s.onerror = s.onabort = s.ontimeout = s.onreadystatechange = null, 'abort' === e ? s.abort()  : 'error' === e ? 'number' != typeof s.status ? i(0, 'error')  : i(s.status, s.statusText)  : i(Ut[s.status] || s.status, s.statusText, 'text' !== (s.responseType || 'text') || 'string' != typeof s.responseText ? {
              binary: s.response
            }
             : {
              text: s.responseText
            }, s.getAllResponseHeaders()))
          }
        },
        s.onload = n(),
        r = s.onerror = s.ontimeout = n('error'),
        void 0 !== s.onabort ? s.onabort = r : s.onreadystatechange = function () {
          4 === s.readyState && e.setTimeout(function () {
            n && r()
          })
        },
        n = n('abort');
        try {
          s.send(t.hasContent && t.data || null)
        } catch (e) {
          if (n) throw e
        }
      },
      abort: function () {
        n && n()
      }
    }
  }),
  we.ajaxPrefilter(function (e) {
    e.crossDomain && (e.contents.script = !1)
  }),
  we.ajaxSetup({
    accepts: {
      script: 'text/javascript, application/javascript, application/ecmascript, application/x-ecmascript'
    },
    contents: {
      script: /\b(?:java|ecma)script\b/
    },
    converters: {
      'text script': function (e) {
        return we.globalEval(e),
        e
      }
    }
  }),
  we.ajaxPrefilter('script', function (e) {
    void 0 === e.cache && (e.cache = !1),
    e.crossDomain && (e.type = 'GET')
  }),
  we.ajaxTransport('script', function (e) {
    if (e.crossDomain) {
      var t,
      n;
      return {
        send: function (r, o) {
          t = we('<script>').prop({
            charset: e.scriptCharset,
            src: e.url
          }).on('load error', n = function (e) {
            t.remove(),
            n = null,
            e && o('error' === e.type ? 404 : 200, e.type)
          }),
          ae.head.appendChild(t[0])
        },
        abort: function () {
          n && n()
        }
      }
    }
  });
  var Vt = [
  ],
  Gt = /(=)\?(?=&|$)|\?\?/;
  we.ajaxSetup({
    jsonp: 'callback',
    jsonpCallback: function () {
      var e = Vt.pop() || we.expando + '_' + Mt++;
      return this[e] = !0,
      e
    }
  }),
  we.ajaxPrefilter('json jsonp', function (t, n, r) {
    var o,
    i,
    a,
    s = !1 !== t.jsonp && (Gt.test(t.url) ? 'url' : 'string' == typeof t.data && 0 === (t.contentType || '').indexOf('application/x-www-form-urlencoded') && Gt.test(t.data) && 'data');
    if (s || 'jsonp' === t.dataTypes[0]) return o = t.jsonpCallback = ye(t.jsonpCallback) ? t.jsonpCallback()  : t.jsonpCallback,
    s ? t[s] = t[s].replace(Gt, '$1' + o)  : !1 !== t.jsonp && (t.url += (At.test(t.url) ? '&' : '?') + t.jsonp + '=' + o),
    t.converters['script json'] = function () {
      return a || we.error(o + ' was not called'),
      a[0]
    },
    t.dataTypes[0] = 'json',
    i = e[o],
    e[o] = function () {
      a = arguments
    },
    r.always(function () {
      void 0 === i ? we(e).removeProp(o)  : e[o] = i,
      t[o] && (t.jsonpCallback = n.jsonpCallback, Vt.push(o)),
      a && ye(i) && i(a[0]),
      a = i = void 0
    }),
    'script'
  }),
  ve.createHTMLDocument = function () {
    var e = ae.implementation.createHTMLDocument('').body;
    return e.innerHTML = '<form></form><form></form>',
    2 === e.childNodes.length
  }(),
  we.parseHTML = function (e, t, n) {
    if ('string' != typeof e) return [];
    'boolean' == typeof t && (n = t, t = !1);
    var r,
    o,
    i;
    return t || (ve.createHTMLDocument ? ((r = (t = ae.implementation.createHTMLDocument('')).createElement('base')).href = ae.location.href, t.head.appendChild(r))  : t = ae),
    o = De.exec(e),
    i = !n && [
    ],
    o ? [
      t.createElement(o[1])
    ] : (o = C([e], t, i), i && i.length && we(i).remove(), we.merge([], o.childNodes))
  },
  we.fn.load = function (e, t, n) {
    var r,
    o,
    i,
    a = this,
    s = e.indexOf(' ');
    return s > - 1 && (r = Q(e.slice(s)), e = e.slice(0, s)),
    ye(t) ? (n = t, t = void 0)  : t && 'object' == typeof t && (o = 'POST'),
    a.length > 0 && we.ajax({
      url: e,
      type: o || 'GET',
      dataType: 'html',
      data: t
    }).done(function (e) {
      i = arguments,
      a.html(r ? we('<div>').append(we.parseHTML(e)).find(r)  : e)
    }).always(n && function (e, t) {
      a.each(function () {
        n.apply(this, i || [
          e.responseText,
          t,
          e
        ])
      })
    }),
    this
  },
  we.each(['ajaxStart',
  'ajaxStop',
  'ajaxComplete',
  'ajaxError',
  'ajaxSuccess',
  'ajaxSend'], function (e, t) {
    we.fn[t] = function (e) {
      return this.on(t, e)
    }
  }),
  we.expr.pseudos.animated = function (e) {
    return we.grep(we.timers, function (t) {
      return e === t.elem
    }).length
  },
  we.offset = {
    setOffset: function (e, t, n) {
      var r,
      o,
      i,
      a,
      s,
      l,
      c = we.css(e, 'position'),
      u = we(e),
      d = {
      };
      'static' === c && (e.style.position = 'relative'),
      s = u.offset(),
      i = we.css(e, 'top'),
      l = we.css(e, 'left'),
      ('absolute' === c || 'fixed' === c) && (i + l).indexOf('auto') > - 1 ? (a = (r = u.position()).top, o = r.left)  : (a = parseFloat(i) || 0, o = parseFloat(l) || 0),
      ye(t) && (t = t.call(e, n, we.extend({
      }, s))),
      null != t.top && (d.top = t.top - s.top + a),
      null != t.left && (d.left = t.left - s.left + o),
      'using' in t ? t.using.call(e, d)  : u.css(d)
    }
  },
  we.fn.extend({
    offset: function (e) {
      if (arguments.length) return void 0 === e ? this : this.each(function (t) {
        we.offset.setOffset(this, e, t)
      });
      var t,
      n,
      r = this[0];
      return r ? r.getClientRects().length ? (t = r.getBoundingClientRect(), n = r.ownerDocument.defaultView, {
        top: t.top + n.pageYOffset,
        left: t.left + n.pageXOffset
      })  : {
        top: 0,
        left: 0
      }
       : void 0
    },
    position: function () {
      if (this[0]) {
        var e,
        t,
        n,
        r = this[0],
        o = {
          top: 0,
          left: 0
        };
        if ('fixed' === we.css(r, 'position')) t = r.getBoundingClientRect();
         else {
          for (t = this.offset(), n = r.ownerDocument, e = r.offsetParent || n.documentElement; e && (e === n.body || e === n.documentElement) && 'static' === we.css(e, 'position'); ) e = e.parentNode;
          e && e !== r && 1 === e.nodeType && ((o = we(e).offset()).top += we.css(e, 'borderTopWidth', !0), o.left += we.css(e, 'borderLeftWidth', !0))
        }
        return {
          top: t.top - o.top - we.css(r, 'marginTop', !0),
          left: t.left - o.left - we.css(r, 'marginLeft', !0)
        }
      }
    },
    offsetParent: function () {
      return this.map(function () {
        for (var e = this.offsetParent; e && 'static' === we.css(e, 'position'); ) e = e.offsetParent;
        return e || et
      })
    }
  }),
  we.each({
    scrollLeft: 'pageXOffset',
    scrollTop: 'pageYOffset'
  }, function (e, t) {
    var n = 'pageYOffset' === t;
    we.fn[e] = function (r) {
      return Ne(this, function (e, r, o) {
        var i;
        if (xe(e) ? i = e : 9 === e.nodeType && (i = e.defaultView), void 0 === o) return i ? i[t] : e[r];
        i ? i.scrollTo(n ? i.pageXOffset : o, n ? o : i.pageYOffset)  : e[r] = o
      }, e, r, arguments.length)
    }
  }),
  we.each(['top',
  'left'], function (e, t) {
    we.cssHooks[t] = I(ve.pixelPosition, function (e, n) {
      if (n) return n = N(e, t),
      lt.test(n) ? we(e).position() [t] + 'px' : n
    })
  }),
  we.each({
    Height: 'height',
    Width: 'width'
  }, function (e, t) {
    we.each({
      padding: 'inner' + e,
      content: t,
      '': 'outer' + e
    }, function (n, r) {
      we.fn[r] = function (o, i) {
        var a = arguments.length && (n || 'boolean' != typeof o),
        s = n || (!0 === o || !0 === i ? 'margin' : 'border');
        return Ne(this, function (t, n, o) {
          var i;
          return xe(t) ? 0 === r.indexOf('outer') ? t['inner' + e] : t.document.documentElement['client' + e] : 9 === t.nodeType ? (i = t.documentElement, Math.max(t.body['scroll' + e], i['scroll' + e], t.body['offset' + e], i['offset' + e], i['client' + e]))  : void 0 === o ? we.css(t, n, s)  : we.style(t, n, o, s)
        }, t, a ? o : void 0, a)
      }
    })
  }),
  we.each('blur focus focusin focusout resize scroll click dblclick mousedown mouseup mousemove mouseover mouseout mouseenter mouseleave change select submit keydown keypress keyup contextmenu'.split(' '), function (e, t) {
    we.fn[t] = function (e, n) {
      return arguments.length > 0 ? this.on(t, null, e, n)  : this.trigger(t)
    }
  }),
  we.fn.extend({
    hover: function (e, t) {
      return this.mouseenter(e).mouseleave(t || e)
    }
  }),
  we.fn.extend({
    bind: function (e, t, n) {
      return this.on(e, null, t, n)
    },
    unbind: function (e, t) {
      return this.off(e, null, t)
    },
    delegate: function (e, t, n, r) {
      return this.on(t, e, n, r)
    },
    undelegate: function (e, t, n) {
      return 1 === arguments.length ? this.off(e, '**')  : this.off(t, e || '**', n)
    }
  }),
  we.proxy = function (e, t) {
    var n,
    r,
    o;
    if ('string' == typeof t && (n = e[t], t = e, e = n), ye(e)) return r = le.call(arguments, 2),
    o = function () {
      return e.apply(t || this, r.concat(le.call(arguments)))
    },
    o.guid = e.guid = e.guid || we.guid++,
    o
  },
  we.holdReady = function (e) {
    e ? we.readyWait++ : we.ready(!0)
  },
  we.isArray = Array.isArray,
  we.parseJSON = JSON.parse,
  we.nodeName = i,
  we.isFunction = ye,
  we.isWindow = xe,
  we.camelCase = h,
  we.type = r,
  we.now = Date.now,
  we.isNumeric = function (e) {
    var t = we.type(e);
    return ('number' === t || 'string' === t) && !isNaN(e - parseFloat(e))
  },
  'function' == typeof define && define.amd && define('jquery', [
  ], function () {
    return we
  });
  var Qt = e.jQuery,
  Kt = e.$;
  return we.noConflict = function (t) {
    return e.$ === we && (e.$ = Kt),
    t && e.jQuery === we && (e.jQuery = Qt),
    we
  },
  t || (e.jQuery = e.$ = we),
  we
});
var $jscomp = {
  scope: {
  },
  findInternal: function (e, t, n) {
    e instanceof String && (e = String(e));
    for (var r = e.length, o = 0; o < r; o++) {
      var i = e[o];
      if (t.call(n, i, o, e)) return {
        i: o,
        v: i
      }
    }
    return {
      i: - 1,
      v: void 0
    }
  }
};
$jscomp.defineProperty = 'function' == typeof Object.defineProperties ? Object.defineProperty : function (e, t, n) {
  if (n.get || n.set) throw new TypeError('ES3 does not support getters and setters.');
  e != Array.prototype && e != Object.prototype && (e[t] = n.value)
},
$jscomp.getGlobal = function (e) {
  return 'undefined' != typeof window && window === e ? e : 'undefined' != typeof global && null != global ? global : e
},
$jscomp.global = $jscomp.getGlobal(this),
$jscomp.polyfill = function (e, t, n, r) {
  if (t) {
    for (n = $jscomp.global, e = e.split('.'), r = 0; r < e.length - 1; r++) {
      var o = e[r];
      o in n || (n[o] = {
      }),
      n = n[o]
    }
    e = e[e.length - 1],
    r = n[e],
    t = t(r),
    t != r && null != t && $jscomp.defineProperty(n, e, {
      configurable: !0,
      writable: !0,
      value: t
    })
  }
},
$jscomp.polyfill('Array.prototype.find', function (e) {
  return e || function (e, t) {
    return $jscomp.findInternal(this, e, t).v
  }
}, 'es6-impl', 'es3'),
function (e, t, n) {
  'function' == typeof define && define.amd ? define(['jquery'], e)  : 'object' == typeof exports ? module.exports = e(require('jquery'))  : e(t || n)
}(function (e) {
  var t = function (t, n, r) {
    var o = {
      invalid: [
      ],
      getCaret: function () {
        try {
          var e,
          n = 0,
          r = t.get(0),
          i = document.selection,
          a = r.selectionStart;
          return i && - 1 === navigator.appVersion.indexOf('MSIE 10') ? (e = i.createRange(), e.moveStart('character', - o.val().length), n = e.text.length)  : (a || '0' === a) && (n = a),
          n
        } catch (e) {
        }
      },
      setCaret: function (e) {
        try {
          if (t.is(':focus')) {
            var n,
            r = t.get(0);
            r.setSelectionRange ? r.setSelectionRange(e, e)  : (n = r.createTextRange(), n.collapse(!0), n.moveEnd('character', e), n.moveStart('character', e), n.select())
          }
        } catch (e) {
        }
      },
      events: function () {
        t.on('keydown.mask', function (e) {
          t.data('mask-keycode', e.keyCode || e.which),
          t.data('mask-previus-value', t.val()),
          t.data('mask-previus-caret-pos', o.getCaret()),
          o.maskDigitPosMapOld = o.maskDigitPosMap
        }).on(e.jMaskGlobals.useInput ? 'input.mask' : 'keyup.mask', o.behaviour).on('paste.mask drop.mask', function () {
          setTimeout(function () {
            t.keydown().keyup()
          }, 100)
        }).on('change.mask', function () {
          t.data('changed', !0)
        }).on('blur.mask', function () {
          s === o.val() || t.data('changed') || t.trigger('change'),
          t.data('changed', !1)
        }).on('blur.mask', function () {
          s = o.val()
        }).on('focus.mask', function (t) {
          !0 === r.selectOnFocus && e(t.target).select()
        }).on('focusout.mask', function () {
          r.clearIfNotMatch && !i.test(o.val()) && o.val('')
        })
      },
      getRegexMask: function () {
        for (var e, t, r, o, i = [
        ], s = 0; s < n.length; s++) (e = a.translation[n.charAt(s)]) ? (t = e.pattern.toString().replace(/.{1}$|^.{1}/g, ''), r = e.optional, (e = e.recursive) ? (i.push(n.charAt(s)), o = {
          digit: n.charAt(s),
          pattern: t
        })  : i.push(r || e ? t + '?' : t))  : i.push(n.charAt(s).replace(/[-\/\\^$*+?.()|[\]{}]/g, '\\$&'));
        return i = i.join(''),
        o && (i = i.replace(new RegExp('(' + o.digit + '(.*' + o.digit + ')?)'), '($1)?').replace(new RegExp(o.digit, 'g'), o.pattern)),
        new RegExp(i)
      },
      destroyEvents: function () {
        t.off('input keydown keyup paste drop blur focusout '.split(' ').join('.mask '))
      },
      val: function (e) {
        var n = t.is('input') ? 'val' : 'text';
        return 0 < arguments.length ? (t[n]() !== e && t[n](e), n = t)  : n = t[n](),
        n
      },
      calculateCaretPosition: function () {
        var e = t.data('mask-previus-value') || '',
        n = o.getMasked(),
        r = o.getCaret();
        if (e !== n) {
          var i,
          a = t.data('mask-previus-caret-pos') || 0,
          n = n.length,
          s = e.length,
          l = e = 0,
          c = 0,
          u = 0;
          for (i = r; i < n && o.maskDigitPosMap[i]; i++) l++;
          for (i = r - 1; 0 <= i && o.maskDigitPosMap[i]; i--) e++;
          for (i = r - 1; 0 <= i; i--) o.maskDigitPosMap[i] && c++;
          for (i = a - 1; 0 <= i; i--) o.maskDigitPosMapOld[i] && u++;
          r > s ? r = n : a >= r && a !== s ? o.maskDigitPosMapOld[r] || (a = r, r = r - (u - c) - e, o.maskDigitPosMap[r] && (r = a))  : r > a && (r = r + (c - u) + l)
        }
        return r
      },
      behaviour: function (n) {
        n = n || window.event,
        o.invalid = [
        ];
        var r = t.data('mask-keycode');
        if ( - 1 === e.inArray(r, a.byPassKeys)) {
          var r = o.getMasked(),
          i = o.getCaret();
          return setTimeout(function () {
            o.setCaret(o.calculateCaretPosition())
          }, 10),
          o.val(r),
          o.setCaret(i),
          o.callbacks(n)
        }
      },
      getMasked: function (e, t) {
        var i,
        s,
        l = [
        ],
        c = void 0 === t ? o.val()  : t + '',
        u = 0,
        d = n.length,
        f = 0,
        p = c.length,
        h = 1,
        m = 'push',
        g = - 1,
        v = 0,
        y = [
        ];
        r.reverse ? (m = 'unshift', h = - 1, i = 0, u = d - 1, f = p - 1, s = function () {
          return - 1 < u && - 1 < f
        })  : (i = d - 1, s = function () {
          return u < d && f < p
        });
        for (var x; s(); ) {
          var b = n.charAt(u),
          w = c.charAt(f),
          S = a.translation[b];
          S ? (w.match(S.pattern) ? (l[m](w), S.recursive && ( - 1 === g ? g = u : u === i && (u = g - h), i === g && (u -= h)), u += h)  : w === x ? (v--, x = void 0)  : S.optional ? (u += h, f -= h)  : S.fallback ? (l[m](S.fallback), u += h, f -= h)  : o.invalid.push({
            p: f,
            v: w,
            e: S.pattern
          }), f += h)  : (e || l[m](b), w === b ? (y.push(f), f += h)  : (x = b, y.push(f + v), v++), u += h)
        }
        return c = n.charAt(i),
        d !== p + 1 || a.translation[c] || l.push(c),
        l = l.join(''),
        o.mapMaskdigitPositions(l, y, p),
        l
      },
      mapMaskdigitPositions: function (e, t, n) {
        for (e = r.reverse ? e.length - n : 0, o.maskDigitPosMap = {
        }, n = 0; n < t.length; n++) o.maskDigitPosMap[t[n] + e] = 1
      },
      callbacks: function (e) {
        var i = o.val(),
        a = i !== s,
        l = [
          i,
          e,
          t,
          r
        ],
        c = function (e, t, n) {
          'function' == typeof r[e] && t && r[e].apply(this, n)
        };
        c('onChange', !0 === a, l),
        c('onKeyPress', !0 === a, l),
        c('onComplete', i.length === n.length, l),
        c('onInvalid', 0 < o.invalid.length, [
          i,
          e,
          t,
          o.invalid,
          r
        ])
      }
    };
    t = e(t);
    var i,
    a = this,
    s = o.val();
    n = 'function' == typeof n ? n(o.val(), void 0, t, r)  : n,
    a.mask = n,
    a.options = r,
    a.remove = function () {
      var e = o.getCaret();
      return o.destroyEvents(),
      o.val(a.getCleanVal()),
      o.setCaret(e),
      t
    },
    a.getCleanVal = function () {
      return o.getMasked(!0)
    },
    a.getMaskedVal = function (e) {
      return o.getMasked(!1, e)
    },
    a.init = function (s) {
      if (s = s || !1, r = r || {
      }, a.clearIfNotMatch = e.jMaskGlobals.clearIfNotMatch, a.byPassKeys = e.jMaskGlobals.byPassKeys, a.translation = e.extend({
      }, e.jMaskGlobals.translation, r.translation), a = e.extend(!0, {
      }, a, r), i = o.getRegexMask(), s) o.events(),
      o.val(o.getMasked());
       else {
        r.placeholder && t.attr('placeholder', r.placeholder),
        t.data('mask') && t.attr('autocomplete', 'off'),
        s = 0;
        for (var l = !0; s < n.length; s++) {
          var c = a.translation[n.charAt(s)];
          if (c && c.recursive) {
            l = !1;
            break
          }
        }
        l && t.attr('maxlength', n.length),
        o.destroyEvents(),
        o.events(),
        s = o.getCaret(),
        o.val(o.getMasked()),
        o.setCaret(s)
      }
    },
    a.init(!t.is('input'))
  };
  e.maskWatchers = {
  };
  var n = function () {
    var n = e(this),
    o = {
    },
    i = n.attr('data-mask');
    if (n.attr('data-mask-reverse') && (o.reverse = !0), n.attr('data-mask-clearifnotmatch') && (o.clearIfNotMatch = !0), 'true' === n.attr('data-mask-selectonfocus') && (o.selectOnFocus = !0), r(n, i, o)) return n.data('mask', new t(this, i, o))
  },
  r = function (t, n, r) {
    r = r || {
    };
    var o = e(t).data('mask'),
    i = JSON.stringify;
    t = e(t).val() || e(t).text();
    try {
      return 'function' == typeof n && (n = n(t)),
      'object' != typeof o || i(o.options) !== i(r) || o.mask !== n
    } catch (e) {
    }
  },
  o = function (e) {
    var t,
    n = document.createElement('div');
    return e = 'on' + e,
    t = e in n,
    t || (n.setAttribute(e, 'return;'), t = 'function' == typeof n[e]),
    t
  };
  e.fn.mask = function (n, o) {
    o = o || {
    };
    var i = this.selector,
    a = e.jMaskGlobals,
    s = a.watchInterval,
    a = o.watchInputs || a.watchInputs,
    l = function () {
      if (r(this, n, o)) return e(this).data('mask', new t(this, n, o))
    };
    return e(this).each(l),
    i && '' !== i && a && (clearInterval(e.maskWatchers[i]), e.maskWatchers[i] = setInterval(function () {
      e(document).find(i).each(l)
    }, s)),
    this
  },
  e.fn.masked = function (e) {
    return this.data('mask').getMaskedVal(e)
  },
  e.fn.unmask = function () {
    return clearInterval(e.maskWatchers[this.selector]),
    delete e.maskWatchers[this.selector],
    this.each(function () {
      var t = e(this).data('mask');
      t && t.remove().removeData('mask')
    })
  },
  e.fn.cleanVal = function () {
    return this.data('mask').getCleanVal()
  },
  e.applyDataMask = function (t) {
    t = t || e.jMaskGlobals.maskElements,
    (t instanceof e ? t : e(t)).filter(e.jMaskGlobals.dataMaskAttr).each(n)
  },
  o = {
    maskElements: 'input,td,span,div',
    dataMaskAttr: '*[data-mask]',
    dataMask: !0,
    watchInterval: 300,
    watchInputs: !0,
    useInput: !/Chrome\/[2-4][0-9]|SamsungBrowser/.test(window.navigator.userAgent) && o('input'),
    watchDataMask: !1,
    byPassKeys: [
      9,
      16,
      17,
      18,
      36,
      37,
      38,
      39,
      40,
      91
    ],
    translation: {
      0: {
        pattern: /\d/
      },
      9: {
        pattern: /\d/,
        optional: !0
      },
      '#': {
        pattern: /\d/,
        recursive: !0
      },
      A: {
        pattern: /[a-zA-Z0-9]/
      },
      S: {
        pattern: /[a-zA-Z]/
      }
    }
  },
  e.jMaskGlobals = e.jMaskGlobals || {
  },
  o = e.jMaskGlobals = e.extend(!0, {
  }, o, e.jMaskGlobals),
  o.dataMask && e.applyDataMask(),
  setInterval(function () {
    e.jMaskGlobals.watchDataMask && e.applyDataMask()
  }, o.watchInterval)
}, window.jQuery, window.Zepto),
function (e) {
  'function' == typeof define && define.amd ? define(['jquery'], e)  : 'object' == typeof exports ? module.exports = e : e(jQuery)
}(function (e) {
  function t(t) {
    var a = t || window.event,
    s = l.call(arguments, 1),
    c = 0,
    d = 0,
    f = 0,
    p = 0,
    h = 0,
    m = 0;
    if (t = e.event.fix(a), t.type = 'mousewheel', 'detail' in a && (f = - 1 * a.detail), 'wheelDelta' in a && (f = a.wheelDelta), 'wheelDeltaY' in a && (f = a.wheelDeltaY), 'wheelDeltaX' in a && (d = - 1 * a.wheelDeltaX), 'axis' in a && a.axis === a.HORIZONTAL_AXIS && (d = - 1 * f, f = 0), c = 0 === f ? d : f, 'deltaY' in a && (f = - 1 * a.deltaY, c = f), 'deltaX' in a && (d = a.deltaX, 0 === f && (c = - 1 * d)), 0 !== f || 0 !== d) {
      if (1 === a.deltaMode) {
        var g = e.data(this, 'mousewheel-line-height');
        c *= g,
        f *= g,
        d *= g
      } else if (2 === a.deltaMode) {
        var v = e.data(this, 'mousewheel-page-height');
        c *= v,
        f *= v,
        d *= v
      }
      if (p = Math.max(Math.abs(f), Math.abs(d)), (!i || i > p) && (i = p, r(a, p) && (i /= 40)), r(a, p) && (c /= 40, d /= 40, f /= 40), c = Math[c >= 1 ? 'floor' : 'ceil'](c / i), d = Math[d >= 1 ? 'floor' : 'ceil'](d / i), f = Math[f >= 1 ? 'floor' : 'ceil'](f / i), u.settings.normalizeOffset && this.getBoundingClientRect) {
        var y = this.getBoundingClientRect();
        h = t.clientX - y.left,
        m = t.clientY - y.top
      }
      return t.deltaX = d,
      t.deltaY = f,
      t.deltaFactor = i,
      t.offsetX = h,
      t.offsetY = m,
      t.deltaMode = 0,
      s.unshift(t, c, d, f),
      o && clearTimeout(o),
      o = setTimeout(n, 200),
      (e.event.dispatch || e.event.handle).apply(this, s)
    }
  }
  function n() {
    i = null
  }
  function r(e, t) {
    return u.settings.adjustOldDeltas && 'mousewheel' === e.type && t % 120 == 0
  }
  var o,
  i,
  a = [
    'wheel',
    'mousewheel',
    'DOMMouseScroll',
    'MozMousePixelScroll'
  ],
  s = 'onwheel' in document || document.documentMode >= 9 ? [
    'wheel'
  ] : [
    'mousewheel',
    'DomMouseScroll',
    'MozMousePixelScroll'
  ],
  l = Array.prototype.slice;
  if (e.event.fixHooks) for (var c = a.length; c; ) e.event.fixHooks[a[--c]] = e.event.mouseHooks;
  var u = e.event.special.mousewheel = {
    version: '3.1.12',
    setup: function () {
      if (this.addEventListener) for (var n = s.length; n; ) this.addEventListener(s[--n], t, !1);
       else this.onmousewheel = t;
      e.data(this, 'mousewheel-line-height', u.getLineHeight(this)),
      e.data(this, 'mousewheel-page-height', u.getPageHeight(this))
    },
    teardown: function () {
      if (this.removeEventListener) for (var n = s.length; n; ) this.removeEventListener(s[--n], t, !1);
       else this.onmousewheel = null;
      e.removeData(this, 'mousewheel-line-height'),
      e.removeData(this, 'mousewheel-page-height')
    },
    getLineHeight: function (t) {
      var n = e(t),
      r = n['offsetParent' in e.fn ? 'offsetParent' : 'parent']();
      return r.length || (r = e('body')),
      parseInt(r.css('fontSize'), 10) || parseInt(n.css('fontSize'), 10) || 16
    },
    getPageHeight: function (t) {
      return e(t).height()
    },
    settings: {
      adjustOldDeltas: !0,
      normalizeOffset: !0
    }
  };
  e.fn.extend({
    mousewheel: function (e) {
      return e ? this.bind('mousewheel', e)  : this.trigger('mousewheel')
    },
    unmousewheel: function (e) {
      return this.unbind('mousewheel', e)
    }
  })
}),
function (e) {
  'function' == typeof define && define.amd ? define(['jquery'], e)  : 'object' == typeof exports ? module.exports = e : e(jQuery)
}(function (e) {
  function t(t) {
    var a = t || window.event,
    s = l.call(arguments, 1),
    c = 0,
    d = 0,
    f = 0,
    p = 0,
    h = 0,
    m = 0;
    if (t = e.event.fix(a), t.type = 'mousewheel', 'detail' in a && (f = - 1 * a.detail), 'wheelDelta' in a && (f = a.wheelDelta), 'wheelDeltaY' in a && (f = a.wheelDeltaY), 'wheelDeltaX' in a && (d = - 1 * a.wheelDeltaX), 'axis' in a && a.axis === a.HORIZONTAL_AXIS && (d = - 1 * f, f = 0), c = 0 === f ? d : f, 'deltaY' in a && (f = - 1 * a.deltaY, c = f), 'deltaX' in a && (d = a.deltaX, 0 === f && (c = - 1 * d)), 0 !== f || 0 !== d) {
      if (1 === a.deltaMode) {
        var g = e.data(this, 'mousewheel-line-height');
        c *= g,
        f *= g,
        d *= g
      } else if (2 === a.deltaMode) {
        var v = e.data(this, 'mousewheel-page-height');
        c *= v,
        f *= v,
        d *= v
      }
      if (p = Math.max(Math.abs(f), Math.abs(d)), (!i || i > p) && (i = p, r(a, p) && (i /= 40)), r(a, p) && (c /= 40, d /= 40, f /= 40), c = Math[c >= 1 ? 'floor' : 'ceil'](c / i), d = Math[d >= 1 ? 'floor' : 'ceil'](d / i), f = Math[f >= 1 ? 'floor' : 'ceil'](f / i), u.settings.normalizeOffset && this.getBoundingClientRect) {
        var y = this.getBoundingClientRect();
        h = t.clientX - y.left,
        m = t.clientY - y.top
      }
      return t.deltaX = d,
      t.deltaY = f,
      t.deltaFactor = i,
      t.offsetX = h,
      t.offsetY = m,
      t.deltaMode = 0,
      s.unshift(t, c, d, f),
      o && clearTimeout(o),
      o = setTimeout(n, 200),
      (e.event.dispatch || e.event.handle).apply(this, s)
    }
  }
  function n() {
    i = null
  }
  function r(e, t) {
    return u.settings.adjustOldDeltas && 'mousewheel' === e.type && t % 120 == 0
  }
  var o,
  i,
  a = [
    'wheel',
    'mousewheel',
    'DOMMouseScroll',
    'MozMousePixelScroll'
  ],
  s = 'onwheel' in document || document.documentMode >= 9 ? [
    'wheel'
  ] : [
    'mousewheel',
    'DomMouseScroll',
    'MozMousePixelScroll'
  ],
  l = Array.prototype.slice;
  if (e.event.fixHooks) for (var c = a.length; c; ) e.event.fixHooks[a[--c]] = e.event.mouseHooks;
  var u = e.event.special.mousewheel = {
    version: '3.1.12',
    setup: function () {
      if (this.addEventListener) for (var n = s.length; n; ) this.addEventListener(s[--n], t, !1);
       else this.onmousewheel = t;
      e.data(this, 'mousewheel-line-height', u.getLineHeight(this)),
      e.data(this, 'mousewheel-page-height', u.getPageHeight(this))
    },
    teardown: function () {
      if (this.removeEventListener) for (var n = s.length; n; ) this.removeEventListener(s[--n], t, !1);
       else this.onmousewheel = null;
      e.removeData(this, 'mousewheel-line-height'),
      e.removeData(this, 'mousewheel-page-height')
    },
    getLineHeight: function (t) {
      var n = e(t),
      r = n['offsetParent' in e.fn ? 'offsetParent' : 'parent']();
      return r.length || (r = e('body')),
      parseInt(r.css('fontSize'), 10) || parseInt(n.css('fontSize'), 10) || 16
    },
    getPageHeight: function (t) {
      return e(t).height()
    },
    settings: {
      adjustOldDeltas: !0,
      normalizeOffset: !0
    }
  };
  e.fn.extend({
    mousewheel: function (e) {
      return e ? this.bind('mousewheel', e)  : this.trigger('mousewheel')
    },
    unmousewheel: function (e) {
      return this.unbind('mousewheel', e)
    }
  })
}),
function (e) {
  'function' == typeof define && define.amd ? define(['jquery'], e)  : 'undefined' != typeof module && module.exports ? module.exports = e : e(jQuery, window, document)
}(function (e) {
  !function (t) {
    var n = 'function' == typeof define && define.amd,
    r = 'undefined' != typeof module && module.exports,
    o = 'https:' == document.location.protocol ? 'https:' : 'http:';
    n || (r ? require('jquery-mousewheel') (e)  : e.event.special.mousewheel || e('head').append(decodeURI('%3Cscript src=' + o + '//cdnjs.cloudflare.com/ajax/libs/jquery-mousewheel/3.1.13/jquery.mousewheel.min.js%3E%3C/script%3E'))),
    t()
  }(function () {
    var t,
    n = 'mCustomScrollbar',
    r = 'mCS',
    o = '.mCustomScrollbar',
    i = {
      setTop: 0,
      setLeft: 0,
      axis: 'y',
      scrollbarPosition: 'inside',
      scrollInertia: 950,
      autoDraggerLength: !0,
      alwaysShowScrollbar: 0,
      snapOffset: 0,
      mouseWheel: {
        enable: !0,
        scrollAmount: 'auto',
        axis: 'y',
        deltaFactor: 'auto',
        disableOver: [
          'select',
          'option',
          'keygen',
          'datalist',
          'textarea'
        ]
      },
      scrollButtons: {
        scrollType: 'stepless',
        scrollAmount: 'auto'
      },
      keyboard: {
        enable: !0,
        scrollType: 'stepless',
        scrollAmount: 'auto'
      },
      contentTouchScroll: 25,
      documentTouchScroll: !0,
      advanced: {
        autoScrollOnFocus: 'input,textarea,select,button,datalist,keygen,a[tabindex],area,object,[contenteditable=\'true\']',
        updateOnContentResize: !0,
        updateOnImageLoad: 'auto',
        autoUpdateTimeout: 60
      },
      theme: 'light',
      callbacks: {
        onTotalScrollOffset: 0,
        onTotalScrollBackOffset: 0,
        alwaysTriggerOffsets: !0
      }
    },
    a = 0,
    s = {
    },
    l = window.attachEvent && !window.addEventListener ? 1 : 0,
    c = !1,
    u = [
      'mCSB_dragger_onDrag',
      'mCSB_scrollTools_onDrag',
      'mCS_img_loaded',
      'mCS_disabled',
      'mCS_destroyed',
      'mCS_no_scrollbar',
      'mCS-autoHide',
      'mCS-dir-rtl',
      'mCS_no_scrollbar_y',
      'mCS_no_scrollbar_x',
      'mCS_y_hidden',
      'mCS_x_hidden',
      'mCSB_draggerContainer',
      'mCSB_buttonUp',
      'mCSB_buttonDown',
      'mCSB_buttonLeft',
      'mCSB_buttonRight'
    ],
    d = {
      init: function (t) {
        var t = e.extend(!0, {
        }, i, t),
        n = f.call(this);
        if (t.live) {
          var l = t.liveSelector || this.selector || o,
          c = e(l);
          if ('off' === t.live) return void h(l);
          s[l] = setTimeout(function () {
            c.mCustomScrollbar(t),
            'once' === t.live && c.length && h(l)
          }, 500)
        } else h(l);
        return t.setWidth = t.set_width ? t.set_width : t.setWidth,
        t.setHeight = t.set_height ? t.set_height : t.setHeight,
        t.axis = t.horizontalScroll ? 'x' : m(t.axis),
        t.scrollInertia = t.scrollInertia > 0 && t.scrollInertia < 17 ? 17 : t.scrollInertia,
        'object' != typeof t.mouseWheel && 1 == t.mouseWheel && (t.mouseWheel = {
          enable: !0,
          scrollAmount: 'auto',
          axis: 'y',
          preventDefault: !1,
          deltaFactor: 'auto',
          normalizeDelta: !1,
          invert: !1
        }),
        t.mouseWheel.scrollAmount = t.mouseWheelPixels ? t.mouseWheelPixels : t.mouseWheel.scrollAmount,
        t.mouseWheel.normalizeDelta = t.advanced.normalizeMouseWheelDelta ? t.advanced.normalizeMouseWheelDelta : t.mouseWheel.normalizeDelta,
        t.scrollButtons.scrollType = g(t.scrollButtons.scrollType),
        p(t),
        e(n).each(function () {
          var n = e(this);
          if (!n.data(r)) {
            n.data(r, {
              idx: ++a,
              opt: t,
              scrollRatio: {
                y: null,
                x: null
              },
              overflowed: null,
              contentReset: {
                y: null,
                x: null
              },
              bindEvents: !1,
              tweenRunning: !1,
              sequential: {
              },
              langDir: n.css('direction'),
              cbOffsets: null,
              trigger: null,
              poll: {
                size: {
                  o: 0,
                  n: 0
                },
                img: {
                  o: 0,
                  n: 0
                },
                change: {
                  o: 0,
                  n: 0
                }
              }
            });
            var o = n.data(r),
            i = o.opt,
            s = n.data('mcs-axis'),
            l = n.data('mcs-scrollbar-position'),
            c = n.data('mcs-theme');
            s && (i.axis = s),
            l && (i.scrollbarPosition = l),
            c && (i.theme = c, p(i)),
            v.call(this),
            o && i.callbacks.onCreate && 'function' == typeof i.callbacks.onCreate && i.callbacks.onCreate.call(this),
            e('#mCSB_' + o.idx + '_container img:not(.' + u[2] + ')').addClass(u[2]),
            d.update.call(null, n)
          }
        })
      },
      update: function (t, n) {
        var o = t || f.call(this);
        return e(o).each(function () {
          var t = e(this);
          if (t.data(r)) {
            var o = t.data(r),
            i = o.opt,
            a = e('#mCSB_' + o.idx + '_container'),
            s = e('#mCSB_' + o.idx),
            l = [
              e('#mCSB_' + o.idx + '_dragger_vertical'),
              e('#mCSB_' + o.idx + '_dragger_horizontal')
            ];
            if (!a.length) return;
            o.tweenRunning && V(t),
            n && o && i.callbacks.onBeforeUpdate && 'function' == typeof i.callbacks.onBeforeUpdate && i.callbacks.onBeforeUpdate.call(this),
            t.hasClass(u[3]) && t.removeClass(u[3]),
            t.hasClass(u[4]) && t.removeClass(u[4]),
            s.css('max-height', 'none'),
            s.height() !== t.height() && s.css('max-height', t.height()),
            x.call(this),
            'y' === i.axis || i.advanced.autoExpandHorizontalScroll || a.css('width', y(a)),
            o.overflowed = T.call(this),
            E.call(this),
            i.autoDraggerLength && w.call(this),
            S.call(this),
            _.call(this);
            var c = [
              Math.abs(a[0].offsetTop),
              Math.abs(a[0].offsetLeft)
            ];
            'x' !== i.axis && (o.overflowed[0] ? l[0].height() > l[0].parent().height() ? k.call(this)  : (G(t, c[0].toString(), {
              dir: 'y',
              dur: 0,
              overwrite: 'none'
            }), o.contentReset.y = null)  : (k.call(this), 'y' === i.axis ? D.call(this)  : 'yx' === i.axis && o.overflowed[1] && G(t, c[1].toString(), {
              dir: 'x',
              dur: 0,
              overwrite: 'none'
            }))),
            'y' !== i.axis && (o.overflowed[1] ? l[1].width() > l[1].parent().width() ? k.call(this)  : (G(t, c[1].toString(), {
              dir: 'x',
              dur: 0,
              overwrite: 'none'
            }), o.contentReset.x = null)  : (k.call(this), 'x' === i.axis ? D.call(this)  : 'yx' === i.axis && o.overflowed[0] && G(t, c[0].toString(), {
              dir: 'y',
              dur: 0,
              overwrite: 'none'
            }))),
            n && o && (2 === n && i.callbacks.onImageLoad && 'function' == typeof i.callbacks.onImageLoad ? i.callbacks.onImageLoad.call(this)  : 3 === n && i.callbacks.onSelectorChange && 'function' == typeof i.callbacks.onSelectorChange ? i.callbacks.onSelectorChange.call(this)  : i.callbacks.onUpdate && 'function' == typeof i.callbacks.onUpdate && i.callbacks.onUpdate.call(this)),
            U.call(this)
          }
        })
      },
      scrollTo: function (t, n) {
        if (void 0 !== t && null != t) {
          var o = f.call(this);
          return e(o).each(function () {
            var o = e(this);
            if (o.data(r)) {
              var i = o.data(r),
              a = i.opt,
              s = {
                trigger: 'external',
                scrollInertia: a.scrollInertia,
                scrollEasing: 'mcsEaseInOut',
                moveDragger: !1,
                timeout: 60,
                callbacks: !0,
                onStart: !0,
                onUpdate: !0,
                onComplete: !0
              },
              l = e.extend(!0, {
              }, s, n),
              c = $.call(this, t),
              u = l.scrollInertia > 0 && l.scrollInertia < 17 ? 17 : l.scrollInertia;
              c[0] = X.call(this, c[0], 'y'),
              c[1] = X.call(this, c[1], 'x'),
              l.moveDragger && (c[0] *= i.scrollRatio.y, c[1] *= i.scrollRatio.x),
              l.dur = oe() ? 0 : u,
              setTimeout(function () {
                null !== c[0] && void 0 !== c[0] && 'x' !== a.axis && i.overflowed[0] && (l.dir = 'y', l.overwrite = 'all', G(o, c[0].toString(), l)),
                null !== c[1] && void 0 !== c[1] && 'y' !== a.axis && i.overflowed[1] && (l.dir = 'x', l.overwrite = 'none', G(o, c[1].toString(), l))
              }, l.timeout)
            }
          })
        }
      },
      stop: function () {
        var t = f.call(this);
        return e(t).each(function () {
          var t = e(this);
          t.data(r) && V(t)
        })
      },
      disable: function (t) {
        var n = f.call(this);
        return e(n).each(function () {
          var n = e(this);
          n.data(r) && (n.data(r), U.call(this, 'remove'), D.call(this), t && k.call(this), E.call(this, !0), n.addClass(u[3]))
        })
      },
      destroy: function () {
        var t = f.call(this);
        return e(t).each(function () {
          var o = e(this);
          if (o.data(r)) {
            var i = o.data(r),
            a = i.opt,
            s = e('#mCSB_' + i.idx),
            l = e('#mCSB_' + i.idx + '_container'),
            c = e('.mCSB_' + i.idx + '_scrollbar');
            a.live && h(a.liveSelector || e(t).selector),
            U.call(this, 'remove'),
            D.call(this),
            k.call(this),
            o.removeData(r),
            Z(this, 'mcs'),
            c.remove(),
            l.find('img.' + u[2]).removeClass(u[2]),
            s.replaceWith(l.contents()),
            o.removeClass(n + ' _' + r + '_' + i.idx + ' ' + u[6] + ' ' + u[7] + ' ' + u[5] + ' ' + u[3]).addClass(u[4])
          }
        })
      }
    },
    f = function () {
      return 'object' != typeof e(this) || e(this).length < 1 ? o : this
    },
    p = function (t) {
      var n = [
        'rounded',
        'rounded-dark',
        'rounded-dots',
        'rounded-dots-dark'
      ],
      r = [
        'rounded-dots',
        'rounded-dots-dark',
        '3d',
        '3d-dark',
        '3d-thick',
        '3d-thick-dark',
        'inset',
        'inset-dark',
        'inset-2',
        'inset-2-dark',
        'inset-3',
        'inset-3-dark'
      ],
      o = [
        'minimal',
        'minimal-dark'
      ],
      i = [
        'minimal',
        'minimal-dark'
      ],
      a = [
        'minimal',
        'minimal-dark'
      ];
      t.autoDraggerLength = !(e.inArray(t.theme, n) > - 1) && t.autoDraggerLength,
      t.autoExpandScrollbar = !(e.inArray(t.theme, r) > - 1) && t.autoExpandScrollbar,
      t.scrollButtons.enable = !(e.inArray(t.theme, o) > - 1) && t.scrollButtons.enable,
      t.autoHideScrollbar = e.inArray(t.theme, i) > - 1 || t.autoHideScrollbar,
      t.scrollbarPosition = e.inArray(t.theme, a) > - 1 ? 'outside' : t.scrollbarPosition
    },
    h = function (e) {
      s[e] && (clearTimeout(s[e]), Z(s, e))
    },
    m = function (e) {
      return 'yx' === e || 'xy' === e || 'auto' === e ? 'yx' : 'x' === e || 'horizontal' === e ? 'x' : 'y'
    },
    g = function (e) {
      return 'stepped' === e || 'pixels' === e || 'step' === e || 'click' === e ? 'stepped' : 'stepless'
    },
    v = function () {
      var t = e(this),
      o = t.data(r),
      i = o.opt,
      a = i.autoExpandScrollbar ? ' ' + u[1] + '_expand' : '',
      s = [
        '<div id=\'mCSB_' + o.idx + '_scrollbar_vertical\' class=\'mCSB_scrollTools mCSB_' + o.idx + '_scrollbar mCS-' + i.theme + ' mCSB_scrollTools_vertical' + a + '\'><div class=\'' + u[12] + '\'><div id=\'mCSB_' + o.idx + '_dragger_vertical\' class=\'mCSB_dragger\' style=\'position:absolute;\'><div class=\'mCSB_dragger_bar\' /></div><div class=\'mCSB_draggerRail\' /></div></div>',
        '<div id=\'mCSB_' + o.idx + '_scrollbar_horizontal\' class=\'mCSB_scrollTools mCSB_' + o.idx + '_scrollbar mCS-' + i.theme + ' mCSB_scrollTools_horizontal' + a + '\'><div class=\'' + u[12] + '\'><div id=\'mCSB_' + o.idx + '_dragger_horizontal\' class=\'mCSB_dragger\' style=\'position:absolute;\'><div class=\'mCSB_dragger_bar\' /></div><div class=\'mCSB_draggerRail\' /></div></div>'
      ],
      l = 'yx' === i.axis ? 'mCSB_vertical_horizontal' : 'x' === i.axis ? 'mCSB_horizontal' : 'mCSB_vertical',
      c = 'yx' === i.axis ? s[0] + s[1] : 'x' === i.axis ? s[1] : s[0],
      d = 'yx' === i.axis ? '<div id=\'mCSB_' + o.idx + '_container_wrapper\' class=\'mCSB_container_wrapper\' />' : '',
      f = i.autoHideScrollbar ? ' ' + u[6] : '',
      p = 'x' !== i.axis && 'rtl' === o.langDir ? ' ' + u[7] : '';
      i.setWidth && t.css('width', i.setWidth),
      i.setHeight && t.css('height', i.setHeight),
      i.setLeft = 'y' !== i.axis && 'rtl' === o.langDir ? '989999px' : i.setLeft,
      t.addClass(n + ' _' + r + '_' + o.idx + f + p).wrapInner('<div id=\'mCSB_' + o.idx + '\' class=\'mCustomScrollBox mCS-' + i.theme + ' ' + l + '\'><div id=\'mCSB_' + o.idx + '_container\' class=\'mCSB_container\' style=\'position:relative; top:' + i.setTop + '; left:' + i.setLeft + ';\' dir=\'' + o.langDir + '\' /></div>');
      var h = e('#mCSB_' + o.idx),
      m = e('#mCSB_' + o.idx + '_container');
      'y' === i.axis || i.advanced.autoExpandHorizontalScroll || m.css('width', y(m)),
      'outside' === i.scrollbarPosition ? ('static' === t.css('position') && t.css('position', 'relative'), t.css('overflow', 'visible'), h.addClass('mCSB_outside').after(c))  : (h.addClass('mCSB_inside').append(c), m.wrap(d)),
      b.call(this);
      var g = [
        e('#mCSB_' + o.idx + '_dragger_vertical'),
        e('#mCSB_' + o.idx + '_dragger_horizontal')
      ];
      g[0].css('min-height', g[0].height()),
      g[1].css('min-width', g[1].width())
    },
    y = function (t) {
      var n = [
        t[0].scrollWidth,
        Math.max.apply(Math, t.children().map(function () {
          return e(this).outerWidth(!0)
        }).get())
      ],
      r = t.parent().width();
      return n[0] > r ? n[0] : n[1] > r ? n[1] : '100%'
    },
    x = function () {
      var t = e(this),
      n = t.data(r),
      o = n.opt,
      i = e('#mCSB_' + n.idx + '_container');
      if (o.advanced.autoExpandHorizontalScroll && 'y' !== o.axis) {
        i.css({
          width: 'auto',
          'min-width': 0,
          'overflow-x': 'scroll'
        });
        var a = Math.ceil(i[0].scrollWidth);
        3 === o.advanced.autoExpandHorizontalScroll || 2 !== o.advanced.autoExpandHorizontalScroll && a > i.parent().width() ? i.css({
          width: a,
          'min-width': '100%',
          'overflow-x': 'inherit'
        })  : i.css({
          'overflow-x': 'inherit',
          position: 'absolute'
        }).wrap('<div class=\'mCSB_h_wrapper\' style=\'position:relative; left:0; width:999999px;\' />').css({
          width: Math.ceil(i[0].getBoundingClientRect().right + 0.4) - Math.floor(i[0].getBoundingClientRect().left),
          'min-width': '100%',
          position: 'relative'
        }).unwrap()
      }
    },
    b = function () {
      var t = e(this),
      n = t.data(r),
      o = n.opt,
      i = e('.mCSB_' + n.idx + '_scrollbar:first'),
      a = ne(o.scrollButtons.tabindex) ? 'tabindex=\'' + o.scrollButtons.tabindex + '\'' : '',
      s = [
        '<a href=\'#\' class=\'' + u[13] + '\' ' + a + ' />',
        '<a href=\'#\' class=\'' + u[14] + '\' ' + a + ' />',
        '<a href=\'#\' class=\'' + u[15] + '\' ' + a + ' />',
        '<a href=\'#\' class=\'' + u[16] + '\' ' + a + ' />'
      ],
      l = [
        'x' === o.axis ? s[2] : s[0],
        'x' === o.axis ? s[3] : s[1],
        s[2],
        s[3]
      ];
      o.scrollButtons.enable && i.prepend(l[0]).append(l[1]).next('.mCSB_scrollTools').prepend(l[2]).append(l[3])
    },
    w = function () {
      var t = e(this),
      n = t.data(r),
      o = e('#mCSB_' + n.idx),
      i = e('#mCSB_' + n.idx + '_container'),
      a = [
        e('#mCSB_' + n.idx + '_dragger_vertical'),
        e('#mCSB_' + n.idx + '_dragger_horizontal')
      ],
      s = [
        o.height() / i.outerHeight(!1),
        o.width() / i.outerWidth(!1)
      ],
      c = [
        parseInt(a[0].css('min-height')),
        Math.round(s[0] * a[0].parent().height()),
        parseInt(a[1].css('min-width')),
        Math.round(s[1] * a[1].parent().width())
      ],
      u = l && c[1] < c[0] ? c[0] : c[1],
      d = l && c[3] < c[2] ? c[2] : c[3];
      a[0].css({
        height: u,
        'max-height': a[0].parent().height() - 10
      }).find('.mCSB_dragger_bar').css({
        'line-height': c[0] + 'px'
      }),
      a[1].css({
        width: d,
        'max-width': a[1].parent().width() - 10
      })
    },
    S = function () {
      var t = e(this),
      n = t.data(r),
      o = e('#mCSB_' + n.idx),
      i = e('#mCSB_' + n.idx + '_container'),
      a = [
        e('#mCSB_' + n.idx + '_dragger_vertical'),
        e('#mCSB_' + n.idx + '_dragger_horizontal')
      ],
      s = [
        i.outerHeight(!1) - o.height(),
        i.outerWidth(!1) - o.width()
      ],
      l = [
        s[0] / (a[0].parent().height() - a[0].height()),
        s[1] / (a[1].parent().width() - a[1].width())
      ];
      n.scrollRatio = {
        y: l[0],
        x: l[1]
      }
    },
    C = function (e, t, n) {
      var r = n ? u[0] + '_expanded' : '',
      o = e.closest('.mCSB_scrollTools');
      'active' === t ? (e.toggleClass(u[0] + ' ' + r), o.toggleClass(u[1]), e[0]._draggable = e[0]._draggable ? 0 : 1)  : e[0]._draggable || ('hide' === t ? (e.removeClass(u[0]), o.removeClass(u[1]))  : (e.addClass(u[0]), o.addClass(u[1])))
    },
    T = function () {
      var t = e(this),
      n = t.data(r),
      o = e('#mCSB_' + n.idx),
      i = e('#mCSB_' + n.idx + '_container'),
      a = null == n.overflowed ? i.height()  : i.outerHeight(!1),
      s = null == n.overflowed ? i.width()  : i.outerWidth(!1),
      l = i[0].scrollHeight,
      c = i[0].scrollWidth;
      return l > a && (a = l),
      c > s && (s = c),
      [
        a > o.height(),
        s > o.width()
      ]
    },
    k = function () {
      var t = e(this),
      n = t.data(r),
      o = n.opt,
      i = e('#mCSB_' + n.idx),
      a = e('#mCSB_' + n.idx + '_container'),
      s = [
        e('#mCSB_' + n.idx + '_dragger_vertical'),
        e('#mCSB_' + n.idx + '_dragger_horizontal')
      ];
      if (V(t), ('x' !== o.axis && !n.overflowed[0] || 'y' === o.axis && n.overflowed[0]) && (s[0].add(a).css('top', 0), G(t, '_resetY')), 'y' !== o.axis && !n.overflowed[1] || 'x' === o.axis && n.overflowed[1]) {
        var l = dx = 0;
        'rtl' === n.langDir && (l = i.width() - a.outerWidth(!1), dx = Math.abs(l / n.scrollRatio.x)),
        a.css('left', l),
        s[1].css('left', dx),
        G(t, '_resetX')
      }
    },
    _ = function () {
      function t() {
        a = setTimeout(function () {
          e.event.special.mousewheel ? (clearTimeout(a), O.call(n[0]))  : t()
        }, 100)
      }
      var n = e(this),
      o = n.data(r),
      i = o.opt;
      if (!o.bindEvents) {
        if (A.call(this), i.contentTouchScroll && j.call(this), B.call(this), i.mouseWheel.enable) {
          var a;
          t()
        }
        H.call(this),
        R.call(this),
        i.advanced.autoScrollOnFocus && q.call(this),
        i.scrollButtons.enable && W.call(this),
        i.keyboard.enable && z.call(this),
        o.bindEvents = !0
      }
    },
    D = function () {
      var t = e(this),
      n = t.data(r),
      o = n.opt,
      i = r + '_' + n.idx,
      a = '.mCSB_' + n.idx + '_scrollbar',
      s = e('#mCSB_' + n.idx + ',#mCSB_' + n.idx + '_container,#mCSB_' + n.idx + '_container_wrapper,' + a + ' .' + u[12] + ',#mCSB_' + n.idx + '_dragger_vertical,#mCSB_' + n.idx + '_dragger_horizontal,' + a + '>a'),
      l = e('#mCSB_' + n.idx + '_container');
      o.advanced.releaseDraggableSelectors && s.add(e(o.advanced.releaseDraggableSelectors)),
      o.advanced.extraDraggableSelectors && s.add(e(o.advanced.extraDraggableSelectors)),
      n.bindEvents && (e(document).add(e(!N() || top.document)).unbind('.' + i), s.each(function () {
        e(this).unbind('.' + i)
      }), clearTimeout(t[0]._focusTimeout), Z(t[0], '_focusTimeout'), clearTimeout(n.sequential.step), Z(n.sequential, 'step'), clearTimeout(l[0].onCompleteTimeout), Z(l[0], 'onCompleteTimeout'), n.bindEvents = !1)
    },
    E = function (t) {
      var n = e(this),
      o = n.data(r),
      i = o.opt,
      a = e('#mCSB_' + o.idx + '_container_wrapper'),
      s = a.length ? a : e('#mCSB_' + o.idx + '_container'),
      l = [
        e('#mCSB_' + o.idx + '_scrollbar_vertical'),
        e('#mCSB_' + o.idx + '_scrollbar_horizontal')
      ],
      c = [
        l[0].find('.mCSB_dragger'),
        l[1].find('.mCSB_dragger')
      ];
      'x' !== i.axis && (o.overflowed[0] && !t ? (l[0].add(c[0]).add(l[0].children('a')).css('display', 'block'), s.removeClass(u[8] + ' ' + u[10]))  : (i.alwaysShowScrollbar ? (2 !== i.alwaysShowScrollbar && c[0].css('display', 'none'), s.removeClass(u[10]))  : (l[0].css('display', 'none'), s.addClass(u[10])), s.addClass(u[8]))),
      'y' !== i.axis && (o.overflowed[1] && !t ? (l[1].add(c[1]).add(l[1].children('a')).css('display', 'block'), s.removeClass(u[9] + ' ' + u[11]))  : (i.alwaysShowScrollbar ? (2 !== i.alwaysShowScrollbar && c[1].css('display', 'none'), s.removeClass(u[11]))  : (l[1].css('display', 'none'), s.addClass(u[11])), s.addClass(u[9]))),
      o.overflowed[0] || o.overflowed[1] ? n.removeClass(u[5])  : n.addClass(u[5])
    },
    M = function (t) {
      var n = t.type,
      r = t.target.ownerDocument !== document && null !== frameElement ? [
        e(frameElement).offset().top,
        e(frameElement).offset().left
      ] : null,
      o = N() && t.target.ownerDocument !== top.document && null !== frameElement ? [
        e(t.view.frameElement).offset().top,
        e(t.view.frameElement).offset().left
      ] : [
        0,
        0
      ];
      switch (n) {
        case 'pointerdown':
        case 'MSPointerDown':
        case 'pointermove':
        case 'MSPointerMove':
        case 'pointerup':
        case 'MSPointerUp':
          return r ? [
            t.originalEvent.pageY - r[0] + o[0],
            t.originalEvent.pageX - r[1] + o[1],
            !1
          ] : [
            t.originalEvent.pageY,
            t.originalEvent.pageX,
            !1
          ];
        case 'touchstart':
        case 'touchmove':
        case 'touchend':
          var i = t.originalEvent.touches[0] || t.originalEvent.changedTouches[0],
          a = t.originalEvent.touches.length || t.originalEvent.changedTouches.length;
          return t.target.ownerDocument !== document ? [
            i.screenY,
            i.screenX,
            a > 1
          ] : [
            i.pageY,
            i.pageX,
            a > 1
          ];
        default:
          return r ? [
            t.pageY - r[0] + o[0],
            t.pageX - r[1] + o[1],
            !1
          ] : [
            t.pageY,
            t.pageX,
            !1
          ]
      }
    },
    A = function () {
      function t(e, t, r, o) {
        if (p[0].idleTimer = u.scrollInertia < 233 ? 250 : 0, n.attr('id') === f[1]) var i = 'x',
        l = (n[0].offsetLeft - t + o) * s.scrollRatio.x;
         else var i = 'y',
        l = (n[0].offsetTop - e + r) * s.scrollRatio.y;
        G(a, l.toString(), {
          dir: i,
          drag: !0
        })
      }
      var n,
      o,
      i,
      a = e(this),
      s = a.data(r),
      u = s.opt,
      d = r + '_' + s.idx,
      f = [
        'mCSB_' + s.idx + '_dragger_vertical',
        'mCSB_' + s.idx + '_dragger_horizontal'
      ],
      p = e('#mCSB_' + s.idx + '_container'),
      h = e('#' + f[0] + ',#' + f[1]),
      m = u.advanced.releaseDraggableSelectors ? h.add(e(u.advanced.releaseDraggableSelectors))  : h,
      g = u.advanced.extraDraggableSelectors ? e(!N() || top.document).add(e(u.advanced.extraDraggableSelectors))  : e(!N() || top.document);
      h.bind('contextmenu.' + d, function (e) {
        e.preventDefault()
      }).bind('mousedown.' + d + ' touchstart.' + d + ' pointerdown.' + d + ' MSPointerDown.' + d, function (t) {
        if (t.stopImmediatePropagation(), t.preventDefault(), ee(t)) {
          c = !0,
          l && (document.onselectstart = function () {
            return !1
          }),
          I.call(p, !1),
          V(a),
          n = e(this);
          var r = n.offset(),
          s = M(t) [0] - r.top,
          d = M(t) [1] - r.left,
          f = n.height() + r.top,
          h = n.width() + r.left;
          f > s && s > 0 && h > d && d > 0 && (o = s, i = d),
          C(n, 'active', u.autoExpandScrollbar)
        }
      }).bind('touchmove.' + d, function (e) {
        e.stopImmediatePropagation(),
        e.preventDefault();
        var r = n.offset(),
        a = M(e) [0] - r.top,
        s = M(e) [1] - r.left;
        t(o, i, a, s)
      }),
      e(document).add(g).bind('mousemove.' + d + ' pointermove.' + d + ' MSPointerMove.' + d, function (e) {
        if (n) {
          var r = n.offset(),
          a = M(e) [0] - r.top,
          s = M(e) [1] - r.left;
          if (o === a && i === s) return;
          t(o, i, a, s)
        }
      }).add(m).bind('mouseup.' + d + ' touchend.' + d + ' pointerup.' + d + ' MSPointerUp.' + d, function () {
        n && (C(n, 'active', u.autoExpandScrollbar), n = null),
        c = !1,
        l && (document.onselectstart = null),
        I.call(p, !0)
      })
    },
    j = function () {
      function n(e) {
        if (!te(e) || c || M(e) [2]) return void (t = 0);
        t = 1,
        S = 0,
        C = 0,
        u = 1,
        T.removeClass('mCS_touch_action');
        var n = A.offset();
        d = M(e) [0] - n.top,
        f = M(e) [1] - n.left,
        P = [
          M(e) [0],
          M(e) [1]
        ]
      }
      function o(e) {
        if (te(e) && !c && !M(e) [2] && (_.documentTouchScroll || e.preventDefault(), e.stopImmediatePropagation(), (!C || S) && u)) {
          g = K();
          var t = E.offset(),
          n = M(e) [0] - t.top,
          r = M(e) [1] - t.left,
          o = 'mcsLinearOut';
          if (B.push(n), O.push(r), P[2] = Math.abs(M(e) [0] - P[0]), P[3] = Math.abs(M(e) [1] - P[1]), k.overflowed[0]) var i = j[0].parent().height() - j[0].height(),
          a = d - n > 0 && n - d > - i * k.scrollRatio.y && (2 * P[3] < P[2] || 'yx' === _.axis);
          if (k.overflowed[1]) var s = j[1].parent().width() - j[1].width(),
          p = f - r > 0 && r - f > - s * k.scrollRatio.x && (2 * P[2] < P[3] || 'yx' === _.axis);
          a || p ? (R || e.preventDefault(), S = 1)  : (C = 1, T.addClass('mCS_touch_action')),
          R && e.preventDefault(),
          b = 'yx' === _.axis ? [
            d - n,
            f - r
          ] : 'x' === _.axis ? [
            null,
            f - r
          ] : [
            d - n,
            null
          ],
          A[0].idleTimer = 250,
          k.overflowed[0] && l(b[0], L, o, 'y', 'all', !0),
          k.overflowed[1] && l(b[1], L, o, 'x', I, !0)
        }
      }
      function i(e) {
        if (!te(e) || c || M(e) [2]) return void (t = 0);
        t = 1,
        e.stopImmediatePropagation(),
        V(T),
        m = K();
        var n = E.offset();
        p = M(e) [0] - n.top,
        h = M(e) [1] - n.left,
        B = [
        ],
        O = [
        ]
      }
      function a(e) {
        if (te(e) && !c && !M(e) [2]) {
          u = 0,
          e.stopImmediatePropagation(),
          S = 0,
          C = 0,
          v = K();
          var t = E.offset(),
          n = M(e) [0] - t.top,
          r = M(e) [1] - t.left;
          if (!(v - g > 30)) {
            x = 1000 / (v - m);
            var o = 'mcsEaseOut',
            i = 2.5 > x,
            a = i ? [
              B[B.length - 2],
              O[O.length - 2]
            ] : [
              0,
              0
            ];
            y = i ? [
              n - a[0],
              r - a[1]
            ] : [
              n - p,
              r - h
            ];
            var d = [
              Math.abs(y[0]),
              Math.abs(y[1])
            ];
            x = i ? [
              Math.abs(y[0] / 4),
              Math.abs(y[1] / 4)
            ] : [
              x,
              x
            ];
            var f = [
              Math.abs(A[0].offsetTop) - y[0] * s(d[0] / x[0], x[0]),
              Math.abs(A[0].offsetLeft) - y[1] * s(d[1] / x[1], x[1])
            ];
            b = 'yx' === _.axis ? [
              f[0],
              f[1]
            ] : 'x' === _.axis ? [
              null,
              f[1]
            ] : [
              f[0],
              null
            ],
            w = [
              4 * d[0] + _.scrollInertia,
              4 * d[1] + _.scrollInertia
            ];
            var T = parseInt(_.contentTouchScroll) || 0;
            b[0] = d[0] > T ? b[0] : 0,
            b[1] = d[1] > T ? b[1] : 0,
            k.overflowed[0] && l(b[0], w[0], o, 'y', I, !1),
            k.overflowed[1] && l(b[1], w[1], o, 'x', I, !1)
          }
        }
      }
      function s(e, t) {
        var n = [
          1.5 * t,
          2 * t,
          t / 1.5,
          t / 2
        ];
        return e > 90 ? t > 4 ? n[0] : n[3] : e > 60 ? t > 3 ? n[3] : n[2] : e > 30 ? t > 8 ? n[1] : t > 6 ? n[0] : t > 4 ? t : n[2] : t > 8 ? t : n[3]
      }
      function l(e, t, n, r, o, i) {
        e && G(T, e.toString(), {
          dur: t,
          scrollEasing: n,
          dir: r,
          overwrite: o,
          drag: i
        })
      }
      var u,
      d,
      f,
      p,
      h,
      m,
      g,
      v,
      y,
      x,
      b,
      w,
      S,
      C,
      T = e(this),
      k = T.data(r),
      _ = k.opt,
      D = r + '_' + k.idx,
      E = e('#mCSB_' + k.idx),
      A = e('#mCSB_' + k.idx + '_container'),
      j = [
        e('#mCSB_' + k.idx + '_dragger_vertical'),
        e('#mCSB_' + k.idx + '_dragger_horizontal')
      ],
      B = [
      ],
      O = [
      ],
      L = 0,
      I = 'yx' === _.axis ? 'none' : 'all',
      P = [
      ],
      H = A.find('iframe'),
      q = [
        'touchstart.' + D + ' pointerdown.' + D + ' MSPointerDown.' + D,
        'touchmove.' + D + ' pointermove.' + D + ' MSPointerMove.' + D,
        'touchend.' + D + ' pointerup.' + D + ' MSPointerUp.' + D
      ],
      R = void 0 !== document.body.style.touchAction && '' !== document.body.style.touchAction;
      A.bind(q[0], function (e) {
        n(e)
      }).bind(q[1], function (e) {
        o(e)
      }),
      E.bind(q[0], function (e) {
        i(e)
      }).bind(q[2], function (e) {
        a(e)
      }),
      H.length && H.each(function () {
        e(this).bind('load', function () {
          N(this) && e(this.contentDocument || this.contentWindow.document).bind(q[0], function (e) {
            n(e),
            i(e)
          }).bind(q[1], function (e) {
            o(e)
          }).bind(q[2], function (e) {
            a(e)
          })
        })
      })
    },
    B = function () {
      function n() {
        return window.getSelection ? window.getSelection().toString()  : document.selection && 'Control' != document.selection.type ? document.selection.createRange().text : 0
      }
      function o(e, t, n) {
        u.type = n && i ? 'stepped' : 'stepless',
        u.scrollAmount = 10,
        F(a, e, t, 'mcsLinearOut', n ? 60 : null)
      }
      var i,
      a = e(this),
      s = a.data(r),
      l = s.opt,
      u = s.sequential,
      d = r + '_' + s.idx,
      f = e('#mCSB_' + s.idx + '_container'),
      p = f.parent();
      f.bind('mousedown.' + d, function () {
        t || i || (i = 1, c = !0)
      }).add(document).bind('mousemove.' + d, function (e) {
        if (!t && i && n()) {
          var r = f.offset(),
          a = M(e) [0] - r.top + f[0].offsetTop,
          c = M(e) [1] - r.left + f[0].offsetLeft;
          a > 0 && a < p.height() && c > 0 && c < p.width() ? u.step && o('off', null, 'stepped')  : ('x' !== l.axis && s.overflowed[0] && (0 > a ? o('on', 38)  : a > p.height() && o('on', 40)), 'y' !== l.axis && s.overflowed[1] && (0 > c ? o('on', 37)  : c > p.width() && o('on', 39)))
        }
      }).bind('mouseup.' + d + ' dragend.' + d, function () {
        t || (i && (i = 0, o('off', null)), c = !1)
      })
    },
    O = function () {
      function t(t, r) {
        if (V(n), !P(n, t.target)) {
          var a = 'auto' !== i.mouseWheel.deltaFactor ? parseInt(i.mouseWheel.deltaFactor)  : l && t.deltaFactor < 100 ? 100 : t.deltaFactor || 100,
          u = i.scrollInertia;
          if ('x' === i.axis || 'x' === i.mouseWheel.axis) var d = 'x',
          f = [
            Math.round(a * o.scrollRatio.x),
            parseInt(i.mouseWheel.scrollAmount)
          ],
          p = 'auto' !== i.mouseWheel.scrollAmount ? f[1] : f[0] >= s.width() ? 0.9 * s.width()  : f[0],
          h = Math.abs(e('#mCSB_' + o.idx + '_container') [0].offsetLeft),
          m = c[1][0].offsetLeft,
          g = c[1].parent().width() - c[1].width(),
          v = 'y' === i.mouseWheel.axis ? t.deltaY || r : t.deltaX;
           else var d = 'y',
          f = [
            Math.round(a * o.scrollRatio.y),
            parseInt(i.mouseWheel.scrollAmount)
          ],
          p = 'auto' !== i.mouseWheel.scrollAmount ? f[1] : f[0] >= s.height() ? 0.9 * s.height()  : f[0],
          h = Math.abs(e('#mCSB_' + o.idx + '_container') [0].offsetTop),
          m = c[0][0].offsetTop,
          g = c[0].parent().height() - c[0].height(),
          v = t.deltaY || r;
          'y' === d && !o.overflowed[0] || 'x' === d && !o.overflowed[1] || ((i.mouseWheel.invert || t.webkitDirectionInvertedFromDevice) && (v = - v), i.mouseWheel.normalizeDelta && (v = 0 > v ? - 1 : 1), (v > 0 && 0 !== m || 0 > v && m !== g || i.mouseWheel.preventDefault) && (t.stopImmediatePropagation(), t.preventDefault()), t.deltaFactor < 5 && !i.mouseWheel.normalizeDelta && (p = t.deltaFactor, u = 17), G(n, (h - v * p).toString(), {
            dir: d,
            dur: u
          }))
        }
      }
      if (e(this).data(r)) {
        var n = e(this),
        o = n.data(r),
        i = o.opt,
        a = r + '_' + o.idx,
        s = e('#mCSB_' + o.idx),
        c = [
          e('#mCSB_' + o.idx + '_dragger_vertical'),
          e('#mCSB_' + o.idx + '_dragger_horizontal')
        ],
        u = e('#mCSB_' + o.idx + '_container').find('iframe');
        u.length && u.each(function () {
          e(this).bind('load', function () {
            N(this) && e(this.contentDocument || this.contentWindow.document).bind('mousewheel.' + a, function (e, n) {
              t(e, n)
            })
          })
        }),
        s.bind('mousewheel.' + a, function (e, n) {
          t(e, n)
        })
      }
    },
    L = new Object,
    N = function (t) {
      var n = !1,
      r = !1,
      o = null;
      if (void 0 === t ? r = '#empty' : void 0 !== e(t).attr('id') && (r = e(t).attr('id')), !1 !== r && void 0 !== L[r]) return L[r];
      if (t) {
        try {
          var i = t.contentDocument || t.contentWindow.document;
          o = i.body.innerHTML
        } catch (e) {
        }
        n = null !== o
      } else {
        try {
          var i = top.document;
          o = i.body.innerHTML
        } catch (e) {
        }
        n = null !== o
      }
      return !1 !== r && (L[r] = n),
      n
    },
    I = function (e) {
      var t = this.find('iframe');
      if (t.length) {
        var n = e ? 'auto' : 'none';
        t.css('pointer-events', n)
      }
    },
    P = function (t, n) {
      var o = n.nodeName.toLowerCase(),
      i = t.data(r).opt.mouseWheel.disableOver,
      a = [
        'select',
        'textarea'
      ];
      return e.inArray(o, i) > - 1 && !(e.inArray(o, a) > - 1 && !e(n).is(':focus'))
    },
    H = function () {
      var t,
      n = e(this),
      o = n.data(r),
      i = r + '_' + o.idx,
      a = e('#mCSB_' + o.idx + '_container'),
      s = a.parent();
      e('.mCSB_' + o.idx + '_scrollbar .' + u[12]).bind('mousedown.' + i + ' touchstart.' + i + ' pointerdown.' + i + ' MSPointerDown.' + i, function (n) {
        c = !0,
        e(n.target).hasClass('mCSB_dragger') || (t = 1)
      }).bind('touchend.' + i + ' pointerup.' + i + ' MSPointerUp.' + i, function () {
        c = !1
      }).bind('click.' + i, function (r) {
        if (t && (t = 0, e(r.target).hasClass(u[12]) || e(r.target).hasClass('mCSB_draggerRail'))) {
          V(n);
          var i = e(this),
          l = i.find('.mCSB_dragger');
          if (i.parent('.mCSB_scrollTools_horizontal').length > 0) {
            if (!o.overflowed[1]) return;
            var c = 'x',
            d = r.pageX > l.offset().left ? - 1 : 1,
            f = Math.abs(a[0].offsetLeft) - d * (0.9 * s.width())
          } else {
            if (!o.overflowed[0]) return;
            var c = 'y',
            d = r.pageY > l.offset().top ? - 1 : 1,
            f = Math.abs(a[0].offsetTop) - d * (0.9 * s.height())
          }
          G(n, f.toString(), {
            dir: c,
            scrollEasing: 'mcsEaseInOut'
          })
        }
      })
    },
    q = function () {
      var t = e(this),
      n = t.data(r),
      o = n.opt,
      i = r + '_' + n.idx,
      a = e('#mCSB_' + n.idx + '_container'),
      s = a.parent();
      a.bind('focusin.' + i, function () {
        var n = e(document.activeElement),
        r = a.find('.mCustomScrollBox').length,
        i = 0;
        n.is(o.advanced.autoScrollOnFocus) && (V(t), clearTimeout(t[0]._focusTimeout), t[0]._focusTimer = r ? (i + 17) * r : 0, t[0]._focusTimeout = setTimeout(function () {
          var e = [
            re(n) [0],
            re(n) [1]
          ],
          r = [
            a[0].offsetTop,
            a[0].offsetLeft
          ],
          l = [
            r[0] + e[0] >= 0 && r[0] + e[0] < s.height() - n.outerHeight(!1),
            r[1] + e[1] >= 0 && r[0] + e[1] < s.width() - n.outerWidth(!1)
          ],
          c = 'yx' !== o.axis || l[0] || l[1] ? 'all' : 'none';
          'x' === o.axis || l[0] || G(t, e[0].toString(), {
            dir: 'y',
            scrollEasing: 'mcsEaseInOut',
            overwrite: c,
            dur: i
          }),
          'y' === o.axis || l[1] || G(t, e[1].toString(), {
            dir: 'x',
            scrollEasing: 'mcsEaseInOut',
            overwrite: c,
            dur: i
          })
        }, t[0]._focusTimer))
      })
    },
    R = function () {
      var t = e(this),
      n = t.data(r),
      o = r + '_' + n.idx,
      i = e('#mCSB_' + n.idx + '_container').parent();
      i.bind('scroll.' + o, function () {
        0 === i.scrollTop() && 0 === i.scrollLeft() || e('.mCSB_' + n.idx + '_scrollbar').css('visibility', 'hidden')
      })
    },
    W = function () {
      var t = e(this),
      n = t.data(r),
      o = n.opt,
      i = n.sequential,
      a = r + '_' + n.idx,
      s = '.mCSB_' + n.idx + '_scrollbar';
      e(s + '>a').bind('contextmenu.' + a, function (e) {
        e.preventDefault()
      }).bind('mousedown.' + a + ' touchstart.' + a + ' pointerdown.' + a + ' MSPointerDown.' + a + ' mouseup.' + a + ' touchend.' + a + ' pointerup.' + a + ' MSPointerUp.' + a + ' mouseout.' + a + ' pointerout.' + a + ' MSPointerOut.' + a + ' click.' + a, function (r) {
        function a(e, n) {
          i.scrollAmount = o.scrollButtons.scrollAmount,
          F(t, e, n)
        }
        if (r.preventDefault(), ee(r)) {
          var s = e(this).attr('class');
          switch (i.type = o.scrollButtons.scrollType, r.type) {
            case 'mousedown':
            case 'touchstart':
            case 'pointerdown':
            case 'MSPointerDown':
              if ('stepped' === i.type) return;
              c = !0,
              n.tweenRunning = !1,
              a('on', s);
              break;
            case 'mouseup':
            case 'touchend':
            case 'pointerup':
            case 'MSPointerUp':
            case 'mouseout':
            case 'pointerout':
            case 'MSPointerOut':
              if ('stepped' === i.type) return;
              c = !1,
              i.dir && a('off', s);
              break;
            case 'click':
              if ('stepped' !== i.type || n.tweenRunning) return;
              a('on', s)
          }
        }
      })
    },
    z = function () {
      function t(t) {
        function r(e, t) {
          a.type = i.keyboard.scrollType,
          a.scrollAmount = i.keyboard.scrollAmount,
          'stepped' === a.type && o.tweenRunning || F(n, e, t)
        }
        switch (t.type) {
          case 'blur':
            o.tweenRunning && a.dir && r('off', null);
            break;
          case 'keydown':
          case 'keyup':
            var s = t.keyCode ? t.keyCode : t.which,
            l = 'on';
            if ('x' !== i.axis && (38 === s || 40 === s) || 'y' !== i.axis && (37 === s || 39 === s)) {
              if ((38 === s || 40 === s) && !o.overflowed[0] || (37 === s || 39 === s) && !o.overflowed[1]) return;
              'keyup' === t.type && (l = 'off'),
              e(document.activeElement).is(d) || (t.preventDefault(), t.stopImmediatePropagation(), r(l, s))
            } else if (33 === s || 34 === s) {
              if ((o.overflowed[0] || o.overflowed[1]) && (t.preventDefault(), t.stopImmediatePropagation()), 'keyup' === t.type) {
                V(n);
                var f = 34 === s ? - 1 : 1;
                if ('x' === i.axis || 'yx' === i.axis && o.overflowed[1] && !o.overflowed[0]) var p = 'x',
                h = Math.abs(c[0].offsetLeft) - f * (0.9 * u.width());
                 else var p = 'y',
                h = Math.abs(c[0].offsetTop) - f * (0.9 * u.height());
                G(n, h.toString(), {
                  dir: p,
                  scrollEasing: 'mcsEaseInOut'
                })
              }
            } else if ((35 === s || 36 === s) && !e(document.activeElement).is(d) && ((o.overflowed[0] || o.overflowed[1]) && (t.preventDefault(), t.stopImmediatePropagation()), 'keyup' === t.type)) {
              if ('x' === i.axis || 'yx' === i.axis && o.overflowed[1] && !o.overflowed[0]) var p = 'x',
              h = 35 === s ? Math.abs(u.width() - c.outerWidth(!1))  : 0;
               else var p = 'y',
              h = 35 === s ? Math.abs(u.height() - c.outerHeight(!1))  : 0;
              G(n, h.toString(), {
                dir: p,
                scrollEasing: 'mcsEaseInOut'
              })
            }
        }
      }
      var n = e(this),
      o = n.data(r),
      i = o.opt,
      a = o.sequential,
      s = r + '_' + o.idx,
      l = e('#mCSB_' + o.idx),
      c = e('#mCSB_' + o.idx + '_container'),
      u = c.parent(),
      d = 'input,textarea,select,datalist,keygen,[contenteditable=\'true\']',
      f = c.find('iframe'),
      p = [
        'blur.' + s + ' keydown.' + s + ' keyup.' + s
      ];
      f.length && f.each(function () {
        e(this).bind('load', function () {
          N(this) && e(this.contentDocument || this.contentWindow.document).bind(p[0], function (e) {
            t(e)
          })
        })
      }),
      l.attr('tabindex', '0').bind(p[0], function (e) {
        t(e)
      })
    },
    F = function (t, n, o, i, a) {
      function s(e) {
        d.snapAmount && (f.scrollAmount = d.snapAmount instanceof Array ? 'x' === f.dir[0] ? d.snapAmount[1] : d.snapAmount[0] : d.snapAmount);
        var n = 'stepped' !== f.type,
        r = a || (e ? n ? m / 1.5 : g : 1000 / 60),
        o = e ? n ? 7.5 : 40 : 2.5,
        l = [
          Math.abs(p[0].offsetTop),
          Math.abs(p[0].offsetLeft)
        ],
        u = [
          c.scrollRatio.y > 10 ? 10 : c.scrollRatio.y,
          c.scrollRatio.x > 10 ? 10 : c.scrollRatio.x
        ],
        h = 'x' === f.dir[0] ? l[1] + f.dir[1] * (u[1] * o)  : l[0] + f.dir[1] * (u[0] * o),
        v = 'x' === f.dir[0] ? l[1] + f.dir[1] * parseInt(f.scrollAmount)  : l[0] + f.dir[1] * parseInt(f.scrollAmount),
        y = 'auto' !== f.scrollAmount ? v : h,
        x = i || (e ? n ? 'mcsLinearOut' : 'mcsEaseInOut' : 'mcsLinear'),
        b = !!e;
        return e && 17 > r && (y = 'x' === f.dir[0] ? l[1] : l[0]),
        G(t, y.toString(), {
          dir: f.dir[0],
          scrollEasing: x,
          dur: r,
          onComplete: b
        }),
        e ? void (f.dir = !1)  : (clearTimeout(f.step), void (f.step = setTimeout(function () {
          s()
        }, r)))
      }
      function l() {
        clearTimeout(f.step),
        Z(f, 'step'),
        V(t)
      }
      var c = t.data(r),
      d = c.opt,
      f = c.sequential,
      p = e('#mCSB_' + c.idx + '_container'),
      h = 'stepped' === f.type,
      m = d.scrollInertia < 26 ? 26 : d.scrollInertia,
      g = d.scrollInertia < 1 ? 17 : d.scrollInertia;
      switch (n) {
        case 'on':
          if (f.dir = [
            o === u[16] || o === u[15] || 39 === o || 37 === o ? 'x' : 'y',
            o === u[13] || o === u[15] || 38 === o || 37 === o ? - 1 : 1
          ], V(t), ne(o) && 'stepped' === f.type) return;
          s(h);
          break;
        case 'off':
          l(),
          (h || c.tweenRunning && f.dir) && s(!0)
      }
    },
    $ = function (t) {
      var n = e(this).data(r).opt,
      o = [
      ];
      return 'function' == typeof t && (t = t()),
      t instanceof Array ? o = t.length > 1 ? [
        t[0],
        t[1]
      ] : 'x' === n.axis ? [
        null,
        t[0]
      ] : [
        t[0],
        null
      ] : (o[0] = t.y ? t.y : t.x || 'x' === n.axis ? null : t, o[1] = t.x ? t.x : t.y || 'y' === n.axis ? null : t),
      'function' == typeof o[0] && (o[0] = o[0]()),
      'function' == typeof o[1] && (o[1] = o[1]()),
      o
    },
    X = function (t, n) {
      if (null != t && void 0 !== t) {
        var o = e(this),
        i = o.data(r),
        a = i.opt,
        s = e('#mCSB_' + i.idx + '_container'),
        l = s.parent(),
        c = typeof t;
        n || (n = 'x' === a.axis ? 'x' : 'y');
        var u = 'x' === n ? s.outerWidth(!1) - l.width()  : s.outerHeight(!1) - l.height(),
        f = 'x' === n ? s[0].offsetLeft : s[0].offsetTop,
        p = 'x' === n ? 'left' : 'top';
        switch (c) {
          case 'function':
            return t();
          case 'object':
            var h = t.jquery ? t : e(t);
            if (!h.length) return;
            return 'x' === n ? re(h) [1] : re(h) [0];
          case 'string':
          case 'number':
            if (ne(t)) return Math.abs(t);
            if ( - 1 !== t.indexOf('%')) return Math.abs(u * parseInt(t) / 100);
            if ( - 1 !== t.indexOf('-=')) return Math.abs(f - parseInt(t.split('-=') [1]));
            if ( - 1 !== t.indexOf('+=')) {
              var m = f + parseInt(t.split('+=') [1]);
              return m >= 0 ? 0 : Math.abs(m)
            }
            if ( - 1 !== t.indexOf('px') && ne(t.split('px') [0])) return Math.abs(t.split('px') [0]);
            if ('top' === t || 'left' === t) return 0;
            if ('bottom' === t) return Math.abs(l.height() - s.outerHeight(!1));
            if ('right' === t) return Math.abs(l.width() - s.outerWidth(!1));
            if ('first' === t || 'last' === t) {
              var h = s.find(':' + t);
              return 'x' === n ? re(h) [1] : re(h) [0]
            }
            return e(t).length ? 'x' === n ? re(e(t)) [1] : re(e(t)) [0] : (s.css(p, t), void d.update.call(null, o[0]))
        }
      }
    },
    U = function (t) {
      function n() {
        return clearTimeout(f[0].autoUpdate),
        0 === s.parents('html').length ? void (s = null)  : void (f[0].autoUpdate = setTimeout(function () {
          return c.advanced.updateOnSelectorChange && (l.poll.change.n = i(), l.poll.change.n !== l.poll.change.o) ? (l.poll.change.o = l.poll.change.n, void a(3))  : c.advanced.updateOnContentResize && (l.poll.size.n = s[0].scrollHeight + s[0].scrollWidth + f[0].offsetHeight + s[0].offsetHeight + s[0].offsetWidth, l.poll.size.n !== l.poll.size.o) ? (l.poll.size.o = l.poll.size.n, void a(1))  : !c.advanced.updateOnImageLoad || 'auto' === c.advanced.updateOnImageLoad && 'y' === c.axis || (l.poll.img.n = f.find('img').length, l.poll.img.n === l.poll.img.o) ? void ((c.advanced.updateOnSelectorChange || c.advanced.updateOnContentResize || c.advanced.updateOnImageLoad) && n())  : (l.poll.img.o = l.poll.img.n, void f.find('img').each(function () {
            o(this)
          }))
        }, c.advanced.autoUpdateTimeout))
      }
      function o(t) {
        function n(e, t) {
          return function () {
            return t.apply(e, arguments)
          }
        }
        function r() {
          this.onload = null,
          e(t).addClass(u[2]),
          a(2)
        }
        if (e(t).hasClass(u[2])) return void a();
        var o = new Image;
        o.onload = n(o, r),
        o.src = t.src
      }
      function i() {
        !0 === c.advanced.updateOnSelectorChange && (c.advanced.updateOnSelectorChange = '*');
        var e = 0,
        t = f.find(c.advanced.updateOnSelectorChange);
        return c.advanced.updateOnSelectorChange && t.length > 0 && t.each(function () {
          e += this.offsetHeight + this.offsetWidth
        }),
        e
      }
      function a(e) {
        clearTimeout(f[0].autoUpdate),
        d.update.call(null, s[0], e)
      }
      var s = e(this),
      l = s.data(r),
      c = l.opt,
      f = e('#mCSB_' + l.idx + '_container');
      return t ? (clearTimeout(f[0].autoUpdate), void Z(f[0], 'autoUpdate'))  : void n()
    },
    Y = function (e, t, n) {
      return Math.round(e / t) * t - n
    },
    V = function (t) {
      var n = t.data(r);
      e('#mCSB_' + n.idx + '_container,#mCSB_' + n.idx + '_container_wrapper,#mCSB_' + n.idx + '_dragger_vertical,#mCSB_' + n.idx + '_dragger_horizontal').each(function () {
        J.call(this)
      })
    },
    G = function (t, n, o) {
      function i(e) {
        return l && c.callbacks[e] && 'function' == typeof c.callbacks[e]
      }
      function a() {
        return [c.callbacks.alwaysTriggerOffsets || b >= w[0] + T,
        c.callbacks.alwaysTriggerOffsets || - k >= b]
      }
      function s() {
        var e = [
          p[0].offsetTop,
          p[0].offsetLeft
        ],
        n = [
          y[0].offsetTop,
          y[0].offsetLeft
        ],
        r = [
          p.outerHeight(!1),
          p.outerWidth(!1)
        ],
        i = [
          f.height(),
          f.width()
        ];
        t[0].mcs = {
          content: p,
          top: e[0],
          left: e[1],
          draggerTop: n[0],
          draggerLeft: n[1],
          topPct: Math.round(100 * Math.abs(e[0]) / (Math.abs(r[0]) - i[0])),
          leftPct: Math.round(100 * Math.abs(e[1]) / (Math.abs(r[1]) - i[1])),
          direction: o.dir
        }
      }
      var l = t.data(r),
      c = l.opt,
      u = {
        trigger: 'internal',
        dir: 'y',
        scrollEasing: 'mcsEaseOut',
        drag: !1,
        dur: c.scrollInertia,
        overwrite: 'all',
        callbacks: !0,
        onStart: !0,
        onUpdate: !0,
        onComplete: !0
      },
      o = e.extend(u, o),
      d = [
        o.dur,
        o.drag ? 0 : o.dur
      ],
      f = e('#mCSB_' + l.idx),
      p = e('#mCSB_' + l.idx + '_container'),
      h = p.parent(),
      m = c.callbacks.onTotalScrollOffset ? $.call(t, c.callbacks.onTotalScrollOffset)  : [
        0,
        0
      ],
      g = c.callbacks.onTotalScrollBackOffset ? $.call(t, c.callbacks.onTotalScrollBackOffset)  : [
        0,
        0
      ];
      if (l.trigger = o.trigger, 0 === h.scrollTop() && 0 === h.scrollLeft() || (e('.mCSB_' + l.idx + '_scrollbar').css('visibility', 'visible'), h.scrollTop(0).scrollLeft(0)), '_resetY' !== n || l.contentReset.y || (i('onOverflowYNone') && c.callbacks.onOverflowYNone.call(t[0]), l.contentReset.y = 1), '_resetX' !== n || l.contentReset.x || (i('onOverflowXNone') && c.callbacks.onOverflowXNone.call(t[0]), l.contentReset.x = 1), '_resetY' !== n && '_resetX' !== n) {
        if (!l.contentReset.y && t[0].mcs || !l.overflowed[0] || (i('onOverflowY') && c.callbacks.onOverflowY.call(t[0]), l.contentReset.x = null), !l.contentReset.x && t[0].mcs || !l.overflowed[1] || (i('onOverflowX') && c.callbacks.onOverflowX.call(t[0]), l.contentReset.x = null), c.snapAmount) {
          var v = c.snapAmount instanceof Array ? 'x' === o.dir ? c.snapAmount[1] : c.snapAmount[0] : c.snapAmount;
          n = Y(n, v, c.snapOffset)
        }
        switch (o.dir) {
          case 'x':
            var y = e('#mCSB_' + l.idx + '_dragger_horizontal'),
            x = 'left',
            b = p[0].offsetLeft,
            w = [
              f.width() - p.outerWidth(!1),
              y.parent().width() - y.width()
            ],
            S = [
              n,
              0 === n ? 0 : n / l.scrollRatio.x
            ],
            T = m[1],
            k = g[1],
            _ = T > 0 ? T / l.scrollRatio.x : 0,
            D = k > 0 ? k / l.scrollRatio.x : 0;
            break;
          case 'y':
            var y = e('#mCSB_' + l.idx + '_dragger_vertical'),
            x = 'top',
            b = p[0].offsetTop,
            w = [
              f.height() - p.outerHeight(!1),
              y.parent().height() - y.height()
            ],
            S = [
              n,
              0 === n ? 0 : n / l.scrollRatio.y
            ],
            T = m[0],
            k = g[0],
            _ = T > 0 ? T / l.scrollRatio.y : 0,
            D = k > 0 ? k / l.scrollRatio.y : 0
        }
        S[1] < 0 || 0 === S[0] && 0 === S[1] ? S = [
          0,
          0
        ] : S[1] >= w[1] ? S = [
          w[0],
          w[1]
        ] : S[0] = - S[0],
        t[0].mcs || (s(), i('onInit') && c.callbacks.onInit.call(t[0])),
        clearTimeout(p[0].onCompleteTimeout),
        Q(y[0], x, Math.round(S[1]), d[1], o.scrollEasing),
        !l.tweenRunning && (0 === b && S[0] >= 0 || b === w[0] && S[0] <= w[0]) || Q(p[0], x, Math.round(S[0]), d[0], o.scrollEasing, o.overwrite, {
          onStart: function () {
            o.callbacks && o.onStart && !l.tweenRunning && (i('onScrollStart') && (s(), c.callbacks.onScrollStart.call(t[0])), l.tweenRunning = !0, C(y), l.cbOffsets = a())
          },
          onUpdate: function () {
            o.callbacks && o.onUpdate && i('whileScrolling') && (s(), c.callbacks.whileScrolling.call(t[0]))
          },
          onComplete: function () {
            if (o.callbacks && o.onComplete) {
              'yx' === c.axis && clearTimeout(p[0].onCompleteTimeout);
              var e = p[0].idleTimer || 0;
              p[0].onCompleteTimeout = setTimeout(function () {
                i('onScroll') && (s(), c.callbacks.onScroll.call(t[0])),
                i('onTotalScroll') && S[1] >= w[1] - _ && l.cbOffsets[0] && (s(), c.callbacks.onTotalScroll.call(t[0])),
                i('onTotalScrollBack') && S[1] <= D && l.cbOffsets[1] && (s(), c.callbacks.onTotalScrollBack.call(t[0])),
                l.tweenRunning = !1,
                p[0].idleTimer = 0,
                C(y, 'hide')
              }, e)
            }
          }
        })
      }
    },
    Q = function (e, t, n, r, o, i, a) {
      function s() {
        w.stop || (y || h.call(), y = K() - v, l(), y >= w.time && (w.time = y > w.time ? y + f - (y - w.time)  : y + f - 1, w.time < y + 1 && (w.time = y + 1)), w.time < r ? w.id = p(s)  : g.call())
      }
      function l() {
        r > 0 ? (w.currVal = d(w.time, x, S, r, o), b[t] = Math.round(w.currVal) + 'px')  : b[t] = n + 'px',
        m.call()
      }
      function c() {
        f = 1000 / 60,
        w.time = y + f,
        p = window.requestAnimationFrame ? window.requestAnimationFrame : function (e) {
          return l(),
          setTimeout(e, 0.01)
        },
        w.id = p(s)
      }
      function u() {
        null != w.id && (window.requestAnimationFrame ? window.cancelAnimationFrame(w.id)  : clearTimeout(w.id), w.id = null)
      }
      function d(e, t, n, r, o) {
        switch (o) {
          case 'linear':
          case 'mcsLinear':
            return n * e / r + t;
          case 'mcsLinearOut':
            return e /= r,
            e--,
            n * Math.sqrt(1 - e * e) + t;
          case 'easeInOutSmooth':
            return e /= r / 2,
            1 > e ? n / 2 * e * e + t : (e--, - n / 2 * (e * (e - 2) - 1) + t);
          case 'easeInOutStrong':
            return e /= r / 2,
            1 > e ? n / 2 * Math.pow(2, 10 * (e - 1)) + t : (e--, n / 2 * (2 - Math.pow(2, - 10 * e)) + t);
          case 'easeInOut':
          case 'mcsEaseInOut':
            return e /= r / 2,
            1 > e ? n / 2 * e * e * e + t : (e -= 2, n / 2 * (e * e * e + 2) + t);
          case 'easeOutSmooth':
            return e /= r,
            e--,
            - n * (e * e * e * e - 1) + t;
          case 'easeOutStrong':
            return n * (1 - Math.pow(2, - 10 * e / r)) + t;
          case 'easeOut':
          case 'mcsEaseOut':
          default:
            var i = (e /= r) * e,
            a = i * e;
            return t + n * (0.499999999999997 * a * i + - 2.5 * i * i + 5.5 * a + - 6.5 * i + 4 * e)
        }
      }
      e._mTween || (e._mTween = {
        top: {
        },
        left: {
        }
      });
      var f,
      p,
      a = a || {
      },
      h = a.onStart || function () {
      },
      m = a.onUpdate || function () {
      },
      g = a.onComplete || function () {
      },
      v = K(),
      y = 0,
      x = e.offsetTop,
      b = e.style,
      w = e._mTween[t];
      'left' === t && (x = e.offsetLeft);
      var S = n - x;
      w.stop = 0,
      'none' !== i && u(),
      c()
    },
    K = function () {
      return window.performance && window.performance.now ? window.performance.now()  : window.performance && window.performance.webkitNow ? window.performance.webkitNow()  : Date.now ? Date.now()  : (new Date).getTime()
    },
    J = function () {
      var e = this;
      e._mTween || (e._mTween = {
        top: {
        },
        left: {
        }
      });
      for (var t = [
        'top',
        'left'
      ], n = 0; n < t.length; n++) {
        var r = t[n];
        e._mTween[r].id && (window.requestAnimationFrame ? window.cancelAnimationFrame(e._mTween[r].id)  : clearTimeout(e._mTween[r].id), e._mTween[r].id = null, e._mTween[r].stop = 1)
      }
    },
    Z = function (e, t) {
      try {
        delete e[t]
      } catch (n) {
        e[t] = null
      }
    },
    ee = function (e) {
      return !(e.which && 1 !== e.which)
    },
    te = function (e) {
      var t = e.originalEvent.pointerType;
      return !(t && 'touch' !== t && 2 !== t)
    },
    ne = function (e) {
      return !isNaN(parseFloat(e)) && isFinite(e)
    },
    re = function (e) {
      var t = e.parents('.mCSB_container');
      return [e.offset().top - t.offset().top,
      e.offset().left - t.offset().left]
    },
    oe = function () {
      function e() {
        var e = [
          'webkit',
          'moz',
          'ms',
          'o'
        ];
        if ('hidden' in document) return 'hidden';
        for (var t = 0; t < e.length; t++) if (e[t] + 'Hidden' in document) return e[t] + 'Hidden';
        return null
      }
      var t = e();
      return !!t && document[t]
    };
    e.fn[n] = function (t) {
      return d[t] ? d[t].apply(this, Array.prototype.slice.call(arguments, 1))  : 'object' != typeof t && t ? void e.error('Method ' + t + ' does not exist')  : d.init.apply(this, arguments)
    },
    e[n] = function (t) {
      return d[t] ? d[t].apply(this, Array.prototype.slice.call(arguments, 1))  : 'object' != typeof t && t ? void e.error('Method ' + t + ' does not exist')  : d.init.apply(this, arguments)
    },
    e[n].defaults = i,
    window[n] = !0,
    e(window).bind('load', function () {
      e(o) [n](),
      e.extend(e.expr[':'], {
        mcsInView: e.expr[':'].mcsInView || function (t) {
          var n,
          r,
          o = e(t),
          i = o.parents('.mCSB_container');
          if (i.length) return n = i.parent(),
          r = [
            i[0].offsetTop,
            i[0].offsetLeft
          ],
          r[0] + re(o) [0] >= 0 && r[0] + re(o) [0] < n.height() - o.outerHeight(!1) && r[1] + re(o) [1] >= 0 && r[1] + re(o) [1] < n.width() - o.outerWidth(!1)
        },
        mcsInSight: e.expr[':'].mcsInSight || function (t, n, r) {
          var o,
          i,
          a,
          s,
          l = e(t),
          c = l.parents('.mCSB_container'),
          u = 'exact' === r[3] ? [
            [1,
            0],
            [
              1,
              0
            ]
          ] : [
            [0.9,
            0.1],
            [
              0.6,
              0.4
            ]
          ];
          if (c.length) return o = [
            l.outerHeight(!1),
            l.outerWidth(!1)
          ],
          a = [
            c[0].offsetTop + re(l) [0],
            c[0].offsetLeft + re(l) [1]
          ],
          i = [
            c.parent() [0].offsetHeight,
            c.parent() [0].offsetWidth
          ],
          s = [
            o[0] < i[0] ? u[0] : u[1],
            o[1] < i[1] ? u[0] : u[1]
          ],
          a[0] - i[0] * s[0][0] < 0 && a[0] + o[0] - i[0] * s[0][1] >= 0 && a[1] - i[1] * s[1][0] < 0 && a[1] + o[1] - i[1] * s[1][1] >= 0
        },
        mcsOverflow: e.expr[':'].mcsOverflow || function (t) {
          var n = e(t).data(r);
          if (n) return n.overflowed[0] || n.overflowed[1]
        }
      })
    })
  })
});
