# Addigy Password Hint Disabler

This Script will disable the display of password hints on MacOS. This has been tested on 10.13.3 only, but I don't see any reason why it wouldn't work on 10.12  
  
Boring legal stuff:

```text
Copyright 2018 Gavin Weifert-Yeh, Looker Data Sciences Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
```

## Install Script

```bash
#!/bin/bash
/usr/bin/defaults write "/Library/Preferences/com.apple.loginwindow" RetriesUntilHint -int 0
```

## Condition Script

Install on success = FALSE

```bash
#!/bin/bash
if ! /usr/bin/defaults read "/Library/Preferences/com.apple.loginwindow" RetriesUntilHint; then
  exit 1
elif [[ $(/usr/bin/defaults read "/Library/Preferences/com.apple.loginwindow" RetriesUntilHint) != 0 ]]; then
  exit 1
else
  exit 0
fi

```

## Removal Script

I suggest leaving this blank, but the option is here if you want it.

```bash
#!/bin/bash
/usr/bin/defaults delete "/Library/Preferences/com.apple.loginwindow" RetriesUntilHint
```
