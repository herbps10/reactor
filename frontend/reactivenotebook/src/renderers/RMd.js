import React from 'react';
import ReactMarkdown from 'react-markdown';
import RemarkMathPlugin from 'remark-math';
import { InlineMath, BlockMath } from 'react-katex';

const RMd = ({ cell }) => {
    const props = {
        source: cell.resultString(),
        escapeHtml: false,
        plugins: [RemarkMathPlugin],
        renderers: {
            math: (props) => (<BlockMath math={props.value} />),
            inlineMath: (props) => (<InlineMath math={props.value} />)
        }
    }
    return (
        <ReactMarkdown {...props} />
    )
}

export default RMd;