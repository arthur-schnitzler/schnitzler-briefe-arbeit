<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs math"
    version="3.0">
    
    <xsl:mode on-no-match="shallow-copy" />
    <xsl:output indent="true"></xsl:output>
    
    <!-- Template to match the specific condition -->
    <xsl:template match="text()[normalize-space(.)='' and position()=last()
        and parent::tei:note 
        and 
        preceding-sibling::*[1][self::tei:ref[
        
        (@subtype='cf' or @subtype='see' or @subtype='Cf' or @subtype='See')
        ]]
        and 
        not(following-sibling::*)
        ]">
        <xsl:text>.</xsl:text>
    </xsl:template>
    
</xsl:stylesheet>
