# Linux+ (XK0-006) course source

The Linux+ course built into `index.html` is generated from these files.

- `d1-...md` to `d5-...md`: one file per exam domain. This is the master copy. Edit here.
- `md2json.py`: turns the Markdown into the app's course JSON and checks it the same way the app does on import.
- `linux-plus-xk0-006.json`: the output. It can also be loaded on its own in Settings, Course Library.
- `XK0-006-question-bank.md`: all five domains in one readable file.

## Format

```
# MODULE id | Title | Exam label | #hexcolour
## CONCEPT id | Title
idea: / point: / memory:      lesson text
card: front => back           one flashcard

@mc | @tf | @match | @order | @calc
Q: question
* right option    - wrong option        (mc)
- left => right                         (match)
- steps in the correct order            (order)
A: true/false or a number   U: unit     (tf, calc)
E: explanation
```

## Rebuild

```
cd courses/linux-plus && python3 md2json.py
```

Then replace the `builtin-linux` data in `window.BUILTIN_COURSES` in `index.html` with the new JSON.

Totals: 5 modules, 26 concepts, 322 questions, 208 flashcards.
