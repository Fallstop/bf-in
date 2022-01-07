(terpri)
;Read file from args
(defun load-bf-file ()
    (setq arg_file 
        (format nil "~{~a~}" *args*))

    (setq file_contents  
        (with-open-file 
            (instream arg_file :direction :input :if-does-not-exist nil) 
            (let
                ((string (make-string (file-length instream))))
                (read-sequence string instream)
                string
            )
        )
    )
)

; Filter for non-brainfuck charcters

(defvar
    brainfuck-code
    (list)
)

(loop for c in (coerce (load-bf-file) 'list)
    do (
        if (find c "-+<>[],." ) (
            push c brainfuck-code
        )
    ))

; Now reverse to get the correct order ('push' puts it into the front!?!?!?)
(setq brainfuck-code (reverse brainfuck-code))


; Initalize Memory for Execution
(setq memory (make-array 50 :initial-element 0))
(setq pointer 0)
(setq loop-stack (list))

(setq code-pointer 0)

; Start Execution
(loop while (< code-pointer (length brainfuck-code))
    do 
    (setq x (nth code-pointer brainfuck-code))
    (
        case x 
            ((#\+) (setf (aref memory pointer) (+ (aref memory pointer) 1)))
            ((#\-) (setf (aref memory pointer) (- (aref memory pointer) 1)))
            ((#\<) (setf pointer (- pointer 1)))
            ((#\>) (setf pointer (+ pointer 1)))
            ((#\[) (setf loop-stack (append loop-stack (list code-pointer))))
            ((#\]) (
                if (/= (aref memory pointer) 0)
                    (setf code-pointer (car (last loop-stack)))
                    (setf loop-stack (reverse (cdr (reverse loop-stack))))
                ))
            ((#\,) (setf (aref memory pointer) (parse-integer (string (read-char)))))
            ((#\.) (write-char (code-char (aref memory pointer))))
    )
    (setq code-pointer (+ code-pointer 1))
)