<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:oape="https://openarabicpe.github.io/ns"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="3.0">
    <!-- <xsl:output encoding="UTF-8" indent="yes" method="text" omit-xml-declaration="yes"/> -->
    <xsl:strip-space elements="*"/>
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>This stylesheet provides parameters for converting TEI XML to (multi)markdown</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:import href="../../authority-files/xslt/functions.xsl"/>
    <!--<xsl:variable name="v_url-file" select="tei:TEI/tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@type='url']"/>-->
    <xsl:param name="p_compile-serialised-articles" select="true()"/>
    <xsl:param name="p_lang" select="'ar'"/>
    <xsl:param name="p_display-editorial-corrections" select="false()"/>
    <!-- toggle the YAML block at the beginning of each file -->
    <xsl:param name="p_include-yaml" select="false()"/>
    <xsl:variable name="v_include-yaml">
        <xsl:choose>
            <xsl:when test="$p_output-format = 'stylo'">
                <xsl:value-of select="false()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$p_include-yaml"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <!-- values for $p_output-format are: md and stylo -->
    <xsl:param name="p_output-format" select="'stylo'"/>
    <xsl:param name="p_minimal-article-length" select="1000"/>
    <xsl:param name="p_verbose" select="false()"/>

    <!-- locate authority files -->
    <xsl:param name="p_path-authority-files" select="'../../authority-files/data/tei/'"/>
    <xsl:param name="p_file-name-gazetteer" select="'gazetteer_levant-phd.TEIP5.xml'"/>
    <xsl:param name="p_file-name-personography" select="'personography_OpenArabicPE.TEIP5.xml'"/>
    <!-- load the authority files -->
    <xsl:variable name="v_gazetteer" select="doc(concat($p_path-authority-files, $p_file-name-gazetteer))"/>
    <xsl:variable name="v_personography" select="doc(concat($p_path-authority-files, $p_file-name-personography))"/>

    <!-- variables for filenames -->
    <xsl:variable name="v_id-file">
        <xsl:variable name="v_id-file" select="
                if (tei:TEI/@xml:id) then
                    (tei:TEI/@xml:id)
                else
                    (tokenize(base-uri(), '/')[last()])"/>
        <xsl:choose>
            <xsl:when test="$p_output-format = 'stylo'">
                <xsl:value-of select="translate($v_id-file, '_-', '._')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$v_id-file"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="v_biblStruct_file" select="tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:biblStruct[1]"/>
    <xsl:variable name="v_id-oclc" select="$v_biblStruct_file/descendant::tei:idno[@type = 'OCLC'][1]"/>
     <xsl:variable name="v_editor">
            <xsl:choose>
                <xsl:when test="$v_biblStruct_file/tei:monogr/tei:editor/tei:persName[@xml:lang=$p_lang]/tei:surname">
                    <xsl:value-of select="$v_biblStruct_file/tei:monogr/tei:editor/tei:persName[@xml:lang=$p_lang]/tei:surname"/>
                    <xsl:text>, </xsl:text>
                    <xsl:value-of select="$v_biblStruct_file/tei:monogr/tei:editor/tei:persName[@xml:lang=$p_lang]/tei:forename"/>
                </xsl:when>
                <xsl:when test="$v_biblStruct_file/tei:monogr/tei:editor/tei:persName[@xml:lang=$p_lang]">
                    <xsl:value-of select="$v_biblStruct_file/tei:monogr/tei:editor/tei:persName[@xml:lang=$p_lang]"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
    <xsl:variable name="v_issue">
        <xsl:choose>
            <!-- check for correct encoding of issue information -->
            <xsl:when test="$v_biblStruct_file//tei:biblScope[@unit = 'issue']/@from = $v_biblStruct_file//tei:biblScope[@unit = 'issue']/@to">
                <xsl:value-of select="$v_biblStruct_file//tei:biblScope[@unit = 'issue']/@from"/>
            </xsl:when>
            <!-- check for ranges -->
            <xsl:when test="$v_biblStruct_file//tei:biblScope[@unit = 'issue']/@from != $v_biblStruct_file//tei:biblScope[@unit = 'issue']/@to">
                <xsl:value-of select="$v_biblStruct_file//tei:biblScope[@unit = 'issue']/@from"/>
                <!-- probably an en-dash is the better option here -->
                <xsl:text>-</xsl:text>
                <xsl:value-of select="$v_biblStruct_file//tei:biblScope[@unit = 'issue']/@to"/>
            </xsl:when>
            <!-- fallback: erroneous encoding of issue information with @n -->
            <xsl:when test="$v_biblStruct_file//tei:biblScope[@unit = 'issue']/@n">
                <xsl:value-of select="$v_biblStruct_file//tei:biblScope[@unit = 'issue']/@n"/>
            </xsl:when>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="v_volume">
        <xsl:choose>
            <!-- check for correct encoding of volume information -->
            <xsl:when test="$v_biblStruct_file//tei:biblScope[@unit = 'volume']/@from = $v_biblStruct_file//tei:biblScope[@unit = 'volume']/@to">
                <xsl:value-of select="$v_biblStruct_file//tei:biblScope[@unit = 'volume']/@from"/>
            </xsl:when>
            <!-- check for ranges -->
            <xsl:when test="$v_biblStruct_file//tei:biblScope[@unit = 'volume']/@from != $v_biblStruct_file//tei:biblScope[@unit = 'volume']/@to">
                <xsl:value-of select="$v_biblStruct_file//tei:biblScope[@unit = 'volume']/@from"/>
                <!-- probably an en-dash is the better option here -->
                <xsl:text>-</xsl:text>
                <xsl:value-of select="$v_biblStruct_file//tei:biblScope[@unit = 'volume']/@to"/>
            </xsl:when>
            <!-- fallback: erroneous encoding of volume information with @n -->
            <xsl:when test="$v_biblStruct_file//tei:biblScope[@unit = 'volume']/@n">
                <xsl:value-of select="$v_biblStruct_file//tei:biblScope[@unit = 'volume']/@n"/>
            </xsl:when>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="v_file-name-base">
        <xsl:choose>
            <xsl:when test="$p_output-format = 'md'">
                <xsl:value-of select="concat('md/', $v_id-file)"/>
            </xsl:when>
            <xsl:when test="$p_output-format = 'stylo'">
                <!-- author, file, div -->
                <xsl:value-of select="'stylo/'"/>
                <xsl:choose>
                    <xsl:when test="$v_editor/descendant-or-self::tei:persName/@ref">
                        <xsl:value-of select="concat('oape', $v_separator-attribute-value)"/>
                        <xsl:value-of select="oape:query-personography($v_editor/descendant-or-self::tei:persName[1], $v_personography, 'oape', 'id-local', '')"/>
                    </xsl:when>
                    <xsl:when test="$v_editor/descendant-or-self::tei:surname">
                        <xsl:value-of select="$v_editor/descendant-or-self::tei:surname"/>
                    </xsl:when>
                    <xsl:when test="$v_editor/descendant-or-self::tei:persName">
                        <xsl:value-of select="$v_editor/descendant-or-self::tei:persName"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>NN</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:value-of select="$v_separator-attribute-key"/>
                <xsl:choose>
                    <xsl:when test="$v_volume = ''">
                        <xsl:value-of select="$v_id-file"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of
                            select="concat('oclc', $v_separator-attribute-value, $v_id-oclc, $v_separator-attribute-key, 'v', $v_separator-attribute-value, translate($v_volume, '/', '-'), $v_separator-attribute-key, 'i', $v_separator-attribute-value, $v_issue)"
                        />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
    </xsl:variable>
    <!-- strings -->
    <xsl:variable name="v_new-line" select="'&#x0A;'"/>
    <xsl:variable name="v_separator-attribute-key">
        <xsl:choose>
            <xsl:when test="$p_output-format = 'stylo'">
                <xsl:text>_</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>-</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="v_separator-attribute-value">
        <xsl:choose>
            <xsl:when test="$p_output-format = 'stylo'">
                <xsl:text>.</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>_</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <!-- variables for normalizing arabic -->
    <xsl:variable name="v_string-normalise-stylo-arabic-source" select="'اآأإئىؤ'"/>
    <xsl:variable name="v_string-normalise-stylo-arabic-target" select="'ااااييو'"/>
    <xsl:variable name="v_string-normalise-shamela-arabic-source" select="'اآأإ'"/>
    <xsl:variable name="v_string-normalise-shamela-arabic-target" select="'اااا'"/>
</xsl:stylesheet>
