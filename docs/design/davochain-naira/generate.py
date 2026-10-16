from pathlib import Path
from fontTools.fontBuilder import FontBuilder
from fontTools.pens.ttGlyphPen import TTGlyphPen
from fontTools.pens.cu2quPen import Cu2QuPen
from fontTools.pens.transformPen import TransformPen
from fontTools.svgLib.path import parse_path
from PIL import Image, ImageDraw, ImageFont
root=Path(__file__).resolve().parents[3]
out=root/'docs/design/davochain-naira';out.mkdir(parents=True,exist_ok=True)
path="M24 10 H47 C75 10 90 27 90 56 C90 85 75 102 47 102 H24 Z M41 28 V84 H47 C64 84 73 74 73 56 C73 38 64 28 47 28 Z M8 39 H61 V49 H8 Z M8 63 H61 V73 H8 Z"
(out/'currency-mark.svg').write_text(f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 98 112" role="img" aria-label="Davochain Naira"><path fill="currentColor" fill-rule="nonzero" d="{path}"/></svg>\n',encoding='utf-8')
fb=FontBuilder(1000,isTTF=True);fb.setupGlyphOrder(['.notdef','space','uniE900'])
pen=TTGlyphPen(None);cu=Cu2QuPen(pen,1.0,reverse_direction=False)
parse_path(path,TransformPen(cu,(8,0,0,-8,0,840)))
empty=TTGlyphPen(None).glyph()
fb.setupGlyf({'.notdef':empty,'space':empty,'uniE900':pen.glyph()})
fb.setupHorizontalMetrics({'.notdef':(784,0),'space':(250,0),'uniE900':(784,64)})
fb.setupHorizontalHeader(ascent=900,descent=-200)
fb.setupCharacterMap({32:'space',0xe900:'uniE900'})
fb.setupNameTable({'familyName':'Davochain Currency Proposal','styleName':'Regular','uniqueFontIdentifier':'DavochainCurrencyProposal-20261016','fullName':'Davochain Currency Proposal Regular','psName':'DavochainCurrencyProposal-Regular','version':'Version 0.1'})
fb.setupOS2(sTypoAscender=900,sTypoDescender=-200,usWinAscent=900,usWinDescent=200)
fb.setupPost();fb.setupMaxp();fb.save(out/'davochain-currency-proposal.ttf')
fontpath=root/'assets/fonts/sora/Sora-Variable.ttf'
def font(size): return ImageFont.truetype(str(fontpath),size)
def glyph(size): return ImageFont.truetype(str(out/'davochain-currency-proposal.ttf'),size)
blue='#135CF7';ink='#1C1C1C';muted='#686868';paper='#FFFFFF';soft='#EDF2FD';night='#0B1220'
im=Image.new('RGB',(1600,1300),paper);d=ImageDraw.Draw(im)
def txt(x,y,text,size=28,color=ink):
 f=ImageFont.truetype(str(root/'assets/fonts/noto/NotoSans-Regular.ttf'),size) if '\u20a6' in text else font(size)
 d.text((x,y),text,font=f,fill=color)
def mark(x,baseline,size,color): d.text((x,baseline),'\ue900',font=glyph(size),fill=color,anchor='ls')
def money(x,baseline,amount,size,color):
 mark(x,baseline,size,color)
 d.text((x+int(size*.84),baseline),amount,font=font(size),fill=color,anchor='ls')
d.rectangle((0,0,1600,210),fill=blue)
txt(72,52,'Davochain Naira',58,paper);txt(76,138,'Currency mark proposal',24,paper)
mark(104,580,390,blue)
txt(600,280,'A currency mark, made to read.',36)
txt(602,357,'D-shaped silhouette from the Davochain identity.',23,muted)
txt(602,403,'Two currency strokes. One continuous bowl.',23,muted)
txt(602,449,'No dot to confuse with the decimal point.',23,muted)
txt(602,521,'1 Davochain Naira = \u20a61',28)
d.line((72,653,1528,653),fill='#E2E5EB',width=2)
txt(72,692,'In the wallet',25,muted)
d.rounded_rectangle((72,752,972,1030),radius=24,fill=blue)
txt(108,787,'Davochain Naira balance',24,paper)
money(106,921,'125,000.00',80,paper)
txt(110,961,'\u20a6125,000.00 naira value',23,paper)
d.rounded_rectangle((1010,752,1528,1030),radius=24,fill=night)
txt(1048,791,'Small amounts stay clear',22,'#C5CCDA')
money(1046,897,'1.00',66,paper)
money(1049,975,'2,500.75',35,paper)
txt(72,1090,'Readable at everyday sizes',25,muted)
for x,size in [(72,16),(330,22),(650,30),(1040,42)]: money(x,1190,'1,250.00',size,ink)
txt(72,1240,'Proposed custom mark. Illustrative balances. Not a registered Unicode currency sign.',18,muted)
im.save(out/'currency-mark-preview.png')
# A transparent proof exported from the same vector font outlines.
icon=Image.new('RGBA',(512,512));idraw=ImageDraw.Draw(icon)
idraw.text((48,464),'\ue900',font=glyph(510),fill=blue,anchor='ls')
icon.save(out/'currency-mark-blue.png')
print(out)
