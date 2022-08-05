---
title: "README: convert_tei-to-markdown"
subtitle: ""
author: Till Grallert
date: 2022-08-05 
ORCID: orcid.org/0000-0002-5739-8094
---

This repository contains XSLT to convert TEI XML to plain text files with minimal mark-up following the Markdown convention. While it works generally with all TEI encoded files, it is tailored to the needs of [OpenArabicPE](https://openarabicpe.github.io) and its encoding schema.

The code is organised in three levels

1. functions: `functions.xsl`
	- provides all the core templates to be called from individual applications through `mode="m_markdown"`
	- loads functions for extracting bibliographic data from other repositories via **local paths**
2. parameters: `parameters.xsl`
	- provides general settings and is loaded from `functions.xsl`
3. individual applications to generate
	- one file per file
	- one file per `div[@type = 'section]`
	- one file per `div[@type = 'item]`