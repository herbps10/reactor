(window.webpackJsonp=window.webpackJsonp||[]).push([[3],{227:function(t,e,n){!function(t){"use strict";t.registerHelper("wordChars","r",/[\w.]/),t.defineMode("r",function(e){function n(t){for(var e={},n=0;n<t.length;++n)e[t[n]]=!0;return e}var r=["NULL","NA","Inf","NaN","NA_integer_","NA_real_","NA_complex_","NA_character_","TRUE","FALSE"],a=["list","quote","bquote","eval","return","call","parse","deparse"],i=["if","else","repeat","while","function","for","in","next","break"];t.registerHelper("hintWords","r",r.concat(a,i));var o,c=n(r),l=n(a),u=n(i),f=n(["if","else","repeat","while","function","for"]),s=/[+\-*\/^<>=!&|~$:]/;function p(t,e){o=null;var n,r=t.next();if("#"==r)return t.skipToEnd(),"comment";if("0"==r&&t.eat("x"))return t.eatWhile(/[\da-f]/i),"number";if("."==r&&t.eat(/\d/))return t.match(/\d*(?:e[+\-]?\d+)?/),"number";if(/\d/.test(r))return t.match(/\d*(?:\.\d+)?(?:e[+\-]\d+)?L?/),"number";if("'"==r||'"'==r)return e.tokenize=(n=r,function(t,e){if(t.eat("\\")){var r=t.next();return"x"==r?t.match(/^[a-f0-9]{2}/i):("u"==r||"U"==r)&&t.eat("{")&&t.skipTo("}")?t.next():"u"==r?t.match(/^[a-f0-9]{4}/i):"U"==r?t.match(/^[a-f0-9]{8}/i):/[0-7]/.test(r)&&t.match(/^[0-7]{1,2}/),"string-2"}for(var a;null!=(a=t.next());){if(a==n){e.tokenize=p;break}if("\\"==a){t.backUp(1);break}}return"string"}),"string";if("`"==r)return t.match(/[^`]+`/),"variable-3";if("."==r&&t.match(/.[.\d]+/))return"keyword";if(/[\w\.]/.test(r)&&"_"!=r){t.eatWhile(/[\w\.]/);var a=t.current();return c.propertyIsEnumerable(a)?"atom":u.propertyIsEnumerable(a)?(f.propertyIsEnumerable(a)&&!t.match(/\s*if(\s+|$)/,!1)&&(o="block"),"keyword"):l.propertyIsEnumerable(a)?"builtin":"variable"}return"%"==r?(t.skipTo("%")&&t.next(),"operator variable-2"):"<"==r&&t.eat("-")||"<"==r&&t.match("<-")||"-"==r&&t.match(/>>?/)?"operator arrow":"="==r&&e.ctx.argList?"arg-is":s.test(r)?"$"==r?"operator dollar":(t.eatWhile(s),"operator"):/[\(\){}\[\];]/.test(r)?(o=r,";"==r?"semi":null):null}function d(t,e,n){t.ctx={type:e,indent:t.indent,flags:0,column:n.column(),prev:t.ctx}}function m(t,e){var n=t.ctx;t.ctx={type:n.type,indent:n.indent,flags:n.flags|e,column:n.column,prev:n.prev}}function x(t){t.indent=t.ctx.indent,t.ctx=t.ctx.prev}return{startState:function(){return{tokenize:p,ctx:{type:"top",indent:-e.indentUnit,flags:2},indent:0,afterIdent:!1}},token:function(t,e){if(t.sol()&&(0==(3&e.ctx.flags)&&(e.ctx.flags|=2),4&e.ctx.flags&&x(e),e.indent=t.indentation()),t.eatSpace())return null;var n=e.tokenize(t,e);return"comment"!=n&&0==(2&e.ctx.flags)&&m(e,1),";"!=o&&"{"!=o&&"}"!=o||"block"!=e.ctx.type||x(e),"{"==o?d(e,"}",t):"("==o?(d(e,")",t),e.afterIdent&&(e.ctx.argList=!0)):"["==o?d(e,"]",t):"block"==o?d(e,"block",t):o==e.ctx.type?x(e):"block"==e.ctx.type&&"comment"!=n&&m(e,4),e.afterIdent="variable"==n||"keyword"==n,n},indent:function(t,n){if(t.tokenize!=p)return 0;var r=n&&n.charAt(0),a=t.ctx,i=r==a.type;return 4&a.flags&&(a=a.prev),"block"==a.type?a.indent+("{"==r?0:e.indentUnit):1&a.flags?a.column+(i?0:1):a.indent+(i?0:e.indentUnit)},lineComment:"#"}}),t.defineMIME("text/x-rsrc","r")}(n(3))}}]);
//# sourceMappingURL=3.e6f1c4f0.chunk.js.map