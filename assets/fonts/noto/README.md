Noto fallback fonts for exported receipt text.

NotoSans-Regular.ttf: https://github.com/notofonts/noto-fonts/blob/main/hinted/ttf/NotoSans/NotoSans-Regular.ttf
License: OFL.txt from the same repository.
NotoEmoji.ttf: https://github.com/google/fonts/blob/main/ofl/notoemoji/NotoEmoji%5Bwght%5D.ttf
License: OFL-Emoji.txt from the same directory.

Sora is the primary PDF face. Noto Sans supplies missing currency symbols, including Naira; monochrome Noto Emoji supplies common personal-note emoji without rasterizing receipt text.

PDF compatibility: pdf is pinned to 3.13.1. lib/shared/receipts/receipt_pdf_font.dart corrects its ToUnicode output from scalar hex to UTF-16BE surrogate pairs, preserving emoji in selection/copy. The wrapper uses public classes from package src paths because the barrel does not export CMap/DictStream. Revisit the wrapper and run the Unicode CMap regression plus text extraction when upgrading pdf.

NotoSansMath-Regular.ttf: https://github.com/notofonts/noto-fonts/blob/main/hinted/ttf/NotoSansMath/NotoSansMath-Regular.ttf (same OFL.txt license). Supplies mathematical symbols in accepted exchange-rate fields, including U+2248.
