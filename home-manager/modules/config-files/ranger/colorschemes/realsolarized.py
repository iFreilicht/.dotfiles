# This file is part of ranger, the console file manager.
# License: GNU GPL version 3, see the file "AUTHORS" for details.
# Author: Felix Uhl <code@felix-uhl.de>, 2020
# Solarized colorscheme, using actual solarized 4bit codes
# Relies on ranger's default solarized theme for selection of colors
# Also requires the terminal to have the correct colors set for the 4bit
# color codes. See https://ethanschoonover.com/solarized

from __future__ import (absolute_import, division, print_function)

from ranger.colorschemes.solarized import Solarized

base03    = 8  #brblack  234
base02    = 0  #black    235
base01    = 10 #brgreen  240
base00    = 11 #bryellow 241
base0     = 12 #brblue   244
base1     = 14 #brcyan   245
base2     = 7  #white    254
base3     = 15 #brwhite  230
yellow    = 3  #yellow   136
orange    = 9  #brred    166
red       = 1  #red      160
magenta   = 5  #magenta  125
violet    = 13 #brmagenta 61
blue      = 4  #blue      33
cyan      = 6  #cyan      37
green     = 2  #green     64

translation_dict = {
        234: base03,
        235: base02,
        240: base01,
        241: base00,
        244: base0,
        245: base1,
        254: base2,
        230: base3,
        136: yellow,
        166: orange,
        160: red,
        125: magenta,
        61: violet,
        33: blue,
        37: cyan,
        64: green
}

def translate_xterm_to_4bit(xterm_col):
    try:
        return translation_dict[xterm_col]
    except KeyError:
        return xterm_col

class Scheme(Solarized):
    def use(self, context):
        bg, fg, attr = super().use(context)
        bg = translate_xterm_to_4bit(bg)
        fg = translate_xterm_to_4bit(fg)
        return bg, fg, attr
