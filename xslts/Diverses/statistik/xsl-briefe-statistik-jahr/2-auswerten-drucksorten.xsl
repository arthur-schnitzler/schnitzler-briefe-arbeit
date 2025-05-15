<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:foo="whatever" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="3.0">
    <xsl:output method="text" indent="true"/>
    <xsl:mode on-no-match="shallow-copy"/>
 
 <xsl:function name="foo:allejahrewieder">
     <xsl:param name="root" as="node()"/>
     <xsl:param name="target" as="xs:string"/>
     <xsl:param name="jahr"/>
     <xsl:variable name="zaehler" select="count($root/correspondence[@name=$target and @jahr=$jahr])"/>
     <xsl:if test="$zaehler &gt; 0">
         <xsl:value-of select="$zaehler"/>
     </xsl:if>
     <xsl:text>&#9;</xsl:text>
    <xsl:if test="$jahr &lt; 1931">
         <xsl:value-of select="foo:allejahrewieder($root, $target, $jahr +1)"/>
     </xsl:if>
 </xsl:function>
 
 <xsl:template match="root">
     <xsl:variable name="root" select="current()" as="node()"/>
     <xsl:text>Name&#9;1888&#9;1889&#9;1890&#9;1891&#9;1892&#9;1893&#9;1894&#9;1895&#9;1896&#9;1897&#9;1898&#9;1899&#9;1900&#9;1901&#9;1902&#9;1903&#9;1904&#9;1905&#9;1906&#9;1907&#9;1908&#9;1909&#9;1910&#9;1911&#9;1912&#9;1913&#9;1914&#9;1915&#9;1916&#9;1917&#9;1918&#9;1919&#9;1920&#9;1921&#9;1922&#9;1923&#9;1924&#9;1925&#9;1926&#9;1927&#9;1928&#9;1929&#9;1930&#9;1931
</xsl:text>
         <xsl:for-each select="distinct-values(correspondence/@name)">
             <xsl:variable name="target" select="."/>
             <xsl:value-of select="$root/correspondence[@name=$target][1]/@name"/><xsl:text>&#9;</xsl:text>
             <xsl:value-of select="foo:allejahrewieder($root, $target, 1888)"/>
             <xsl:text>
</xsl:text>
         </xsl:for-each>
     
 </xsl:template>
 
 
 
</xsl:stylesheet>
