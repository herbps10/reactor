import CodeMirror from 'codemirror';
import completions from './completions.js';

function suggest(cm, option) {
    return new Promise(function(accept) {
        setTimeout(function() {
            const cursor = cm.getCursor(), line = cm.getLine(cursor.line);

            let start = cursor.ch, end = cursor.ch
            while (start && /\w/.test(line.charAt(start - 1))) --start
            while (end < line.length && /\w/.test(line.charAt(end))) ++end
            var word = line.slice(start, end).toLowerCase()
            const list = [];
            for (let i = 0; i < completions.length; i++) {
                if (completions[i][0].startsWith(word) === true) {
                    list.push({
                        text: completions[i][0],
                        displayText: completions[i][1]
                    })
                }
            }
            if(list.length > 0) {
                return accept({
                    list: list,
                    from: CodeMirror.Pos(cursor.line, start),
                    to: CodeMirror.Pos(cursor.line, end)
                })
            }
            return accept(null)
        }, 100)
    });
}

export default suggest;