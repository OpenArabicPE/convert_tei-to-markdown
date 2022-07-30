<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:oape="https://openarabicpe.github.io/ns" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xpath-default-namespace="http://www.tei-c.org/ns/1.0">
    <xsl:output encoding="UTF-8" indent="yes" method="text" omit-xml-declaration="yes"/>
    <xsl:strip-space elements="*"/>
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>This stylesheet produces a simple markdown file from TEI XML input for every div in the body of the document</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:include href="Tei2Md-functions.xsl"/>
    <xsl:template match="/">
        <xsl:apply-templates mode="m_stylo" select="descendant::tei:text/tei:body/descendant::tei:div[@type = 'item']"/>
    </xsl:template>
    <xsl:template match="div[@type = 'item']" mode="m_stylo">
        <xsl:choose>
            <!-- prevent output for sections of legal texts -->
            <xsl:when test="ancestor::tei:div[@type = 'bill'] or ancestor::tei:div[@subtype = 'bill']"/>
            <!-- prevent output for mastheads -->
            <xsl:when test="@subtype = 'masthead'"/>
            <!-- prevent output for sections of articles -->
            <xsl:when test="ancestor::tei:div[@type = 'item']"/>
            <xsl:otherwise>
                <!-- compile articles if necessary -->
                <xsl:variable name="v_self">
                    <xsl:choose>
                        <!-- if the current article is anything but the first part of a serialised article -->
                        <xsl:when test="@prev and $p_compile-serialised-articles = true()"/>
                        <xsl:when test="@next and $p_compile-serialised-articles = true()">
                            <xsl:copy-of select="oape:compile-next-prev(.)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:copy-of select="."/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="v_length" select="number(count(tokenize(string($v_self), '\W+')))"/>
                <xsl:message>
                    <xsl:text>The div '#</xsl:text><xsl:value-of select="@xml:id"/><xsl:text>' is </xsl:text>
                    <xsl:value-of select="$v_length"/>
                    <xsl:text> words long. The required length is </xsl:text><xsl:value-of select="$p_minimal-article-length"/>
                </xsl:message>
                <!-- output depends on length -->
                <xsl:choose>
                    <xsl:when test="$v_length &gt;= $p_minimal-article-length">
                        <!-- variables identifying the digital surrogate -->
                        <!-- potential to pull author from any one component of a serialised author? -->
                        <xsl:variable name="v_author" select="oape:get-author-from-div(.)"/>
                        <xsl:variable name="v_file-name">
                            <!-- author, file, div -->
                            <xsl:value-of select="concat('stylo/articles/w_', $p_minimal-article-length, '/')"/>
                            <xsl:choose>
                                <xsl:when test="$v_author/descendant-or-self::tei:persName/@ref">
                                    <xsl:value-of select="concat('oape', $v_separator-attribute-value)"/>
                                    <!-- this should only select a single author -->
                                    <xsl:value-of select="oape:query-personography($v_author/$v_author[self::tei:persName/@ref][1], $v_personography, 'oape', 'id-local', '')"/>
                                </xsl:when>
                                <xsl:when test="$v_author/descendant-or-self::tei:surname">
                                    <xsl:value-of select="$v_author/descendant-or-self::tei:surname"/>
                                </xsl:when>
                                <xsl:when test="$v_author/descendant-or-self::tei:persName">
                                    <xsl:value-of select="$v_author/descendant-or-self::tei:persName"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>NN</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:value-of
                                select="concat($v_separator-attribute-key, 'oclc', $v_separator-attribute-value, $v_id-oclc, $v_separator-attribute-key, 'v', $v_separator-attribute-value, translate($v_volume, '/', '-'), $v_separator-attribute-key, 'i', $v_separator-attribute-value, $v_issue, $v_separator-attribute-key, @xml:id, '.txt')"
                            />
                        </xsl:variable>
                        <xsl:result-document href="../_output/{$v_file-name}" method="text">
                            <!-- text body -->
                            <xsl:apply-templates mode="m_markdown" select="$v_self/node()"/>
                        </xsl:result-document>
                    </xsl:when>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
