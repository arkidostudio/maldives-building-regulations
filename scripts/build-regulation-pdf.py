#!/usr/bin/env python3
"""Build the downloadable regulation PDF from the final Markdown source."""

import html
import re
from pathlib import Path

from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import mm
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.platypus import (
    BaseDocTemplate, Frame, HRFlowable, PageTemplate, Paragraph,
    Spacer, Table, TableStyle,
)

ROOT = Path(__file__).resolve().parent.parent
SOURCE = ROOT / "sources/regulation/MD/2019-r-1002-consolidated-second-amendment-en.md"
OUTPUT = ROOT / "sources/regulation/2019-r-1002-consolidated-second-amendment-en.pdf"
pdfmetrics.registerFont(TTFont("NotoThaana", "/System/Library/Fonts/Supplemental/NotoSansThaana-Regular.ttf"))


def inline(text):
    text = html.escape(text.strip())
    text = re.sub(r"([\u0780-\u07bf]+)", r"<font name='NotoThaana'>\1</font>", text)
    text = re.sub(r"\*\*(.+?)\*\*", r"<b>\1</b>", text)
    text = re.sub(r"\*(.+?)\*", r"<i>\1</i>", text)
    text = re.sub(r"`(.+?)`", r"<font name='Courier'>\1</font>", text)
    return text


def footer(canvas, doc):
    canvas.saveState()
    canvas.setFont("Helvetica", 8)
    canvas.setFillColor(colors.HexColor("#6b7280"))
    canvas.drawString(20 * mm, 12 * mm, "2019/R-1002 - Consolidated to the Second Amendment")
    canvas.drawRightString(A4[0] - 20 * mm, 12 * mm, f"Page {doc.page}")
    canvas.restoreState()


def build():
    styles = getSampleStyleSheet()
    styles.add(ParagraphStyle(name="TitleClean", parent=styles["Title"], fontName="Helvetica-Bold", fontSize=20, leading=24, spaceAfter=14, textColor=colors.HexColor("#172033")))
    styles.add(ParagraphStyle(name="H1Clean", parent=styles["Heading1"], fontName="Helvetica-Bold", fontSize=15, leading=19, spaceBefore=16, spaceAfter=8, textColor=colors.HexColor("#172033")))
    styles.add(ParagraphStyle(name="H2Clean", parent=styles["Heading2"], fontName="Helvetica-Bold", fontSize=12, leading=15, spaceBefore=11, spaceAfter=5, textColor=colors.HexColor("#23395d")))
    styles.add(ParagraphStyle(name="BodyClean", parent=styles["BodyText"], fontName="Helvetica", fontSize=9.2, leading=13, spaceAfter=6, textColor=colors.HexColor("#252a34")))
    styles.add(ParagraphStyle(name="NoteClean", parent=styles["BodyClean"], leftIndent=10, borderColor=colors.HexColor("#cbd5e1"), borderWidth=1, borderPadding=7, backColor=colors.HexColor("#f6f8fb")))
    styles.add(ParagraphStyle(name="BulletClean", parent=styles["BodyClean"], leftIndent=14, firstLineIndent=-7, bulletIndent=5))

    doc = BaseDocTemplate(str(OUTPUT), pagesize=A4, rightMargin=18 * mm, leftMargin=18 * mm, topMargin=18 * mm, bottomMargin=20 * mm, title="Regulation on Building in Islands or Lagoons Without Planning Rules", author="Ministry of National Planning and Infrastructure")
    frame = Frame(doc.leftMargin, doc.bottomMargin, doc.width, doc.height, id="body")
    doc.addPageTemplates(PageTemplate(id="main", frames=frame, onPage=footer))

    lines = SOURCE.read_text(encoding="utf-8").splitlines()
    story, paragraph = [], []

    def flush():
        if paragraph:
            story.append(Paragraph(inline(" ".join(paragraph)), styles["BodyClean"]))
            paragraph.clear()

    i = 0
    while i < len(lines):
        line = lines[i].strip()
        if line.startswith("|"):
            flush()
            rows = []
            while i < len(lines) and lines[i].strip().startswith("|"):
                cells = [c.strip() for c in lines[i].strip().strip("|").split("|")]
                if not all(re.fullmatch(r":?-{3,}:?", c) for c in cells):
                    rows.append([Paragraph(inline(c), styles["BodyClean"]) for c in cells])
                i += 1
            table = Table(rows, repeatRows=1, hAlign="LEFT", colWidths=[doc.width / len(rows[0])] * len(rows[0]))
            table.setStyle(TableStyle([("BACKGROUND", (0, 0), (-1, 0), colors.HexColor("#e9eef5")), ("TEXTCOLOR", (0, 0), (-1, 0), colors.HexColor("#172033")), ("GRID", (0, 0), (-1, -1), 0.35, colors.HexColor("#b8c2d1")), ("VALIGN", (0, 0), (-1, -1), "TOP"), ("LEFTPADDING", (0, 0), (-1, -1), 5), ("RIGHTPADDING", (0, 0), (-1, -1), 5), ("TOPPADDING", (0, 0), (-1, -1), 4), ("BOTTOMPADDING", (0, 0), (-1, -1), 4)]))
            story.extend([table, Spacer(1, 7)])
            continue
        if not line:
            flush()
        elif line == "---":
            flush(); story.append(HRFlowable(width="100%", thickness=0.5, color=colors.HexColor("#cbd5e1"), spaceBefore=5, spaceAfter=7))
        elif line.startswith("# "):
            flush(); style = styles["TitleClean"] if not story else styles["H1Clean"]; story.append(Paragraph(inline(line[2:]), style))
        elif line.startswith("## "):
            flush(); story.append(Paragraph(inline(line[3:]), styles["H2Clean"]))
        elif line.startswith("> "):
            flush(); story.append(Paragraph(inline(line[2:]), styles["NoteClean"]))
        elif re.match(r"^[-*] ", line):
            flush(); story.append(Paragraph(inline(line[2:]), styles["BulletClean"], bulletText="-"))
        else:
            paragraph.append(line)
        i += 1
    flush()
    doc.build(story)
    print(OUTPUT)


if __name__ == "__main__":
    build()
