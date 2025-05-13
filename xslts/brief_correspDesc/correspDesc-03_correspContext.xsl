<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" version="3.0">
    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:output method="xml" indent="yes"/>
    <xsl:param name="schnitzler-briefe_cmif"
        select="document('../indices/schnitzler-briefe_cmif.xml')"/>
    <xsl:key name="kontext-lookup" match="tei:correspDesc" use="@key"/>
    <!-- Dieses XSLT nimmt aus /indices/asbw-cmif noch correspContext 
    -->
    <xsl:template match="tei:correspDesc">
        <xsl:element name="correspDesc" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:copy-of select="@* | *[not(name() = 'correspContext')]" copy-namespaces="false"/>
            <xsl:if test="key('kontext-lookup', ancestor::tei:TEI/@xml:id, $schnitzler-briefe_cmif)">
                <xsl:element name="correspContext" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:copy-of select="key('kontext-lookup', ancestor::tei:TEI/@xml:id, $schnitzler-briefe_cmif)/tei:correspContext/*[not(name()='ab')]" copy-namespaces="0"/>
                    
                </xsl:element>
            </xsl:if>
        </xsl:element>
    </xsl:template>
    
    
</xsl:stylesheet>
