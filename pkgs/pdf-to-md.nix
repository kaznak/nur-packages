{
  lib,
  python3,
  writeScriptBin,
}:

# Thin CLI wrapper around pymupdf4llm.to_markdown(). Embedded directly in NUR
# (no separate upstream repo) — upstream provides only a Python API, no CLI.
#
# Usage:
#   pdf-to-md input.pdf output.md
#   pdf-to-md input.pdf output.md --pages 1-5
#   pdf-to-md input.pdf output.json --page-chunks
#
# License: AGPL-3.0+ (inherited from pymupdf4llm; the wrapper imports it, so
# the combined work falls under AGPL).

let
  pythonEnv = python3.withPackages (ps: with ps; [ pymupdf4llm ]);

  script = writeScriptBin "pdf-to-md" ''
    #!${pythonEnv}/bin/python3
    """pymupdf4llm-backed PDF → Markdown CLI."""

    import argparse
    import json
    import sys

    import pymupdf4llm


    def parse_pages(spec: str) -> list[int]:
        """Convert a 1-based page spec like "1-5" or "3" into a 0-indexed list."""
        if "-" in spec:
            start_s, end_s = spec.split("-", 1)
            start, end = int(start_s), int(end_s)
            return list(range(start - 1, end))
        return [int(spec) - 1]


    def main() -> int:
        parser = argparse.ArgumentParser(
            prog="pdf-to-md",
            description="Convert PDF (or other supported documents) to "
            "LLM-friendly Markdown via pymupdf4llm.",
        )
        parser.add_argument("input", help="Input document path (PDF, EPUB, etc.)")
        parser.add_argument(
            "output",
            help="Output path. Plain markdown by default; JSON if --page-chunks.",
        )
        parser.add_argument(
            "--pages",
            metavar="SPEC",
            help='1-based page range, e.g. "1-5" or "3". Default: all pages.',
        )
        parser.add_argument(
            "--page-chunks",
            action="store_true",
            help="Return per-page dicts (metadata + text). Output is JSON.",
        )
        parser.add_argument(
            "--write-images",
            action="store_true",
            help="Extract embedded images alongside the markdown.",
        )
        args = parser.parse_args()

        kwargs: dict = {}
        if args.pages:
            kwargs["pages"] = parse_pages(args.pages)
        if args.page_chunks:
            kwargs["page_chunks"] = True
        if args.write_images:
            kwargs["write_images"] = True

        result = pymupdf4llm.to_markdown(args.input, **kwargs)

        with open(args.output, "w", encoding="utf-8") as f:
            if args.page_chunks:
                json.dump(result, f, ensure_ascii=False, indent=2, default=str)
            else:
                f.write(result)

        return 0


    if __name__ == "__main__":
        sys.exit(main())
  '';
in
script.overrideAttrs (_: {
  meta = with lib; {
    description = "Convert PDF / EPUB / etc. to LLM-friendly Markdown via pymupdf4llm";
    longDescription = ''
      Thin command-line wrapper around the pymupdf4llm Python library
      (which provides only an API, no CLI). Outputs GitHub-flavored Markdown
      reconstructed with reading-order awareness, GFM tables, headings, and
      inline formatting; optionally returns per-page chunks as JSON for
      vector-store ingestion.
    '';
    homepage = "https://github.com/pymupdf/pymupdf4llm";
    license = licenses.agpl3Plus;
    mainProgram = "pdf-to-md";
    platforms = platforms.unix;
  };
})
