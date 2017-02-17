<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tss="http://www.thirdstreetsoftware.com/SenteXML-1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="2.0">
    <xsl:output method="text" encoding="UTF-8" indent="no" omit-xml-declaration="yes"/>
    <xsl:strip-space elements="*"/>
    
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>This stylesheet provides parameters for converting TEI XML to (multi)markdown</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:variable name="vFileId" select="tei:TEI/@xml:id"/>
    <xsl:variable name="vgFileUrl" select="tei:TEI/tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@type='url']"/>
    <xsl:variable name="vN" select="'&#x0A;'"/>
    <xsl:param name="pLang" select="'ar'"/>
    
</xsl:stylesheet>