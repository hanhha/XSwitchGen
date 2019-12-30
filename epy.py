# encoding: utf-8
# Copyright (c) 2008-2009 H.Miyamoto
# Copyright (c) 2007 Makoto Kuwata (TinyEruby)
#
# License: MIT (http://www.opensource.org/licenses/mit-license.php)

r"""A fast and compact implementation of ePython - "embedded Python".

The original implementation created by Makoto Kuwata (www.kuwata-lab.com>).
ePython and epy.py is a python implementation of his logic and eRuby.

cf.) 30 Lines Implementation of eRuby
<http://www.kuwata-lab.com/support/2007/10/09/30-lines-implementation-of-eruby/>
"""

__version_info__ = (0, 7, 3)
__version__ = '0.7.3'
__author__ = 'H.Miyamoto'

import re
import os

class ePython(object):
    def __init__(self, src=None, encoding='utf-8', filename=None, cache=True, cachepath=None):
        self.encoding = encoding
        self.filename = filename

        if src:
            self.src = src
        else:
            self.src = self._read(filename)

        if filename:
            self.cache = cache
            if cachepath:
                self.cachepath = cachepath
            else:
                self.cachepath = '.'.join([filename, 'cache'])
        else:
            self.cache = None
            self.cachepath = ''

        self.delm = '%'
        self.pysrc = None
        self.escfunc = None

    def convert(self):
        if not self.pysrc:
            if self.cached():
                self.pysrc = self._read(self.cachepath)
            else:
                self.__convert()
        if self.cache:
            self._write(self.cachepath, self.pysrc)

        return self.pysrc

    def cached(self):
        return self.cache and \
        os.path.exists(self.filename) and os.path.exists(self.cachepath) and \
        os.path.getmtime(self.filename) < os.path.getmtime(self.cachepath)

    def _read(self, filename):
        fh = open(filename)
        s = fh.read()
        fh.close()

        return s.decode(self.encoding)

    def _write(self, filename, content):
        fh = open(filename, 'w')
        fh.write(content.encode(self.encoding))
        fh.close()

        return

    def __convert(self):
        def _is_avoid_syntax(code):
            return code.endswith(':') and \
                    (code.startswith('else') or \
                     code.startswith('elif') or \
                     code.startswith('except') or \
                     code.startswith('finally'))

        def _convert(mo):
            ret = list()
            text, ch, rawmode, code = mo.groups()
            if text:
                if code.strip() == '':
                    text = text.rstrip('\s').rstrip('\t')
                text = self._esc_quote(text)
                arg = (self._indent * ' ', text.replace('\n', r'\n'))
                ret.append(u"%s_buf.append(u'%s')\n" % arg)
            if ch == '=':
                c = code.strip()
                arg = (self._indent * ' ', c)
                if rawmode:
                    ret.append(u"%s_buf.append(str(%s))\n" % arg)
                else:
                    ret.append(u"%s_buf.append(_esc(str(%s)))\n" % arg)
            elif ch == '#':
                arg = (self._indent * ' ', code.strip())
                ret.append(u"%s# %s\n" % arg)
            else:
                c = code.strip()
                if c == '':
                    self._indent -= 1
                elif _is_avoid_syntax(c):
                    ret.append(''.join([(self._indent - 1) * ' ', c, '\n']))
                else:
                    ret.append(''.join([self._indent * ' ', c, '\n']))
                if c.endswith(':') and not _is_avoid_syntax(c):
                    self._indent += 1
            return ''.join(ret)

        self._indent = 0
        r = re.compile(u'(.*?)<%s([=#])?(r)?(.*?)%s>\n?' % \
                       (self.delm, self.delm), re.MULTILINE | re.DOTALL)
        endmark = u'<%s %s>' % (self.delm, self.delm)

        pysrcbase = u"_buf = []\n%s\n__result = ''.join(_buf)"
        self.pysrc = r.sub(_convert, ''.join([self.src, endmark]))
        self.pysrc = pysrcbase % self.pysrc

        return self.pysrc

    def _esc_quote(self, text):
        return text.replace('\\', '\\\\').replace("'", "\\'")

    def render(self, environ={}):
        if not self.pysrc:
            self.convert()
        if self.escfunc:
            environ['_esc'] = self.escfunc
        else:
            environ['_esc'] = lambda x: x
        exec (self.pysrc, environ)

        return environ['__result']

import cgi

class ePythonHTML(ePython):
    def __init__(self, src=None, encoding='utf-8', filename=None, cache=True):
        super(ePythonHTML, self).__init__(src, encoding, filename, cache)
        self.escfunc = lambda x: cgi.escape(x, quote=True)

