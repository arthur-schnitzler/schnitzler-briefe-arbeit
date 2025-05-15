<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
    <xsl:mode on-no-match="shallow-copy"/>

    <xsl:template match="Geburtsdatum">
        <xsl:variable name="Datumslength" select="string-length(.)"/>
        <Geburtsdatum>
            <xsl:choose>
                <xsl:when test="substring(., 1, 1) = '-'">
                    <xsl:choose>
                        <xsl:when test="$Datumslength = 2">
                            <xsl:text>-000</xsl:text>
                            <xsl:value-of select="substring(., 2, 1)"/>
                            <xsl:text>-00-00</xsl:text>
                        </xsl:when>
                        <xsl:when test="$Datumslength = 3">
                            <xsl:text>-00</xsl:text>
                            <xsl:value-of select="substring(., 2, 2)"/>
                            <xsl:text>-00-00</xsl:text>
                        </xsl:when>
                        <xsl:when test="$Datumslength = 4">
                            <xsl:text>-0</xsl:text>
                            <xsl:value-of select="substring(., 2, 3)"/>
                            <xsl:text>-00-00</xsl:text>
                        </xsl:when>
                        <xsl:when test="$Datumslength = 5">
                            <xsl:text>-</xsl:text>
                            <xsl:value-of select="substring(., 2, 4)"/>
                            <xsl:text>-00-00</xsl:text>
                        </xsl:when>
                        <xsl:when test="$Datumslength = 7">
                            <xsl:text>-</xsl:text>
                            <xsl:value-of select="substring(., 2, 4)"/>
                            <xsl:text>-</xsl:text>
                            <xsl:value-of select="substring(., 6, 2)"/>
                            <xsl:text>-00</xsl:text>
                        </xsl:when>
                        <xsl:when test="$Datumslength = 9">
                            <xsl:text>-</xsl:text>
                            <xsl:value-of select="substring(., 2, 4)"/>
                            <xsl:text>-</xsl:text>
                            <xsl:value-of select="substring(., 6, 2)"/>
                            <xsl:text>-</xsl:text>
                            <xsl:value-of select="substring(., 8, 2)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:if test="not($Datumslength = 0)">
                                <xsl:text>ERROOR</xsl:text>
                            </xsl:if>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="$Datumslength = 1">
                            <xsl:text>000</xsl:text>
                            <xsl:value-of select="substring(., 1, 1)"/>
                            <xsl:text>-00-00</xsl:text>
                        </xsl:when>
                        <xsl:when test="$Datumslength = 2">
                            <xsl:text>00</xsl:text>
                            <xsl:value-of select="substring(., 2, 2)"/>
                            <xsl:text>-00-00</xsl:text>
                        </xsl:when>
                        <xsl:when test="$Datumslength = 3">
                            <xsl:text>0</xsl:text>
                            <xsl:value-of select="substring(., 2, 3)"/>
                            <xsl:text>-00-00</xsl:text>
                        </xsl:when>
                        <xsl:when test="$Datumslength = 4">
                            <xsl:value-of select="substring(., 1, 4)"/>
                            <xsl:text>-00-00</xsl:text>
                        </xsl:when>
                        <xsl:when test="$Datumslength = 6">
                            <xsl:value-of select="substring(., 1, 4)"/>
                            <xsl:text>-</xsl:text>
                            <xsl:value-of select="substring(., 5, 2)"/>
                            <xsl:text>-00</xsl:text>
                        </xsl:when>
                        <xsl:when test="$Datumslength = 8">
                            <xsl:value-of select="substring(., 1, 4)"/>
                            <xsl:text>-</xsl:text>
                            <xsl:value-of select="substring(., 5, 2)"/>
                            <xsl:text>-</xsl:text>
                            <xsl:value-of select="substring(., 7, 2)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:if test="not($Datumslength = 0)">
                                <xsl:text>ERROOR</xsl:text>
                            </xsl:if>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </Geburtsdatum>
    </xsl:template>

    <xsl:template match="Todesdatum">
        <xsl:variable name="Datumslength" select="string-length(.)"/>
        <Todesdatum>
            <xsl:choose>
                <xsl:when test="substring(., 1, 1) = '-'">
                    <xsl:choose>
                        <xsl:when test="$Datumslength = 2">
                            <xsl:text>-000</xsl:text>
                            <xsl:value-of select="substring(., 2, 1)"/>
                            <xsl:text>-00-00</xsl:text>
                        </xsl:when>
                        <xsl:when test="$Datumslength = 3">
                            <xsl:text>-00</xsl:text>
                            <xsl:value-of select="substring(., 2, 2)"/>
                            <xsl:text>-00-00</xsl:text>
                        </xsl:when>
                        <xsl:when test="$Datumslength = 4">
                            <xsl:text>-0</xsl:text>
                            <xsl:value-of select="substring(., 2, 3)"/>
                            <xsl:text>-00-00</xsl:text>
                        </xsl:when>
                        <xsl:when test="$Datumslength = 5">
                            <xsl:text>-</xsl:text>
                            <xsl:value-of select="substring(., 2, 4)"/>
                            <xsl:text>-00-00</xsl:text>
                        </xsl:when>
                        <xsl:when test="$Datumslength = 7">
                            <xsl:text>-</xsl:text>
                            <xsl:value-of select="substring(., 2, 4)"/>
                            <xsl:text>-</xsl:text>
                            <xsl:value-of select="substring(., 6, 2)"/>
                            <xsl:text>-00</xsl:text>
                        </xsl:when>
                        <xsl:when test="$Datumslength = 9">
                            <xsl:text>-</xsl:text>
                            <xsl:value-of select="substring(., 2, 4)"/>
                            <xsl:text>-</xsl:text>
                            <xsl:value-of select="substring(., 6, 2)"/>
                            <xsl:text>-</xsl:text>
                            <xsl:value-of select="substring(., 8, 2)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:if test="not($Datumslength = 0)">
                                <xsl:text>ERROOR</xsl:text>
                            </xsl:if>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="$Datumslength = 1">
                            <xsl:text>000</xsl:text>
                            <xsl:value-of select="substring(., 1, 1)"/>
                            <xsl:text>-00-00</xsl:text>
                        </xsl:when>
                        <xsl:when test="$Datumslength = 2">
                            <xsl:text>00</xsl:text>
                            <xsl:value-of select="substring(., 2, 2)"/>
                            <xsl:text>-00-00</xsl:text>
                        </xsl:when>
                        <xsl:when test="$Datumslength = 3">
                            <xsl:text>0</xsl:text>
                            <xsl:value-of select="substring(., 2, 3)"/>
                            <xsl:text>-00-00</xsl:text>
                        </xsl:when>
                        <xsl:when test="$Datumslength = 4">
                            <xsl:value-of select="substring(., 1, 4)"/>
                            <xsl:text>-00-00</xsl:text>
                        </xsl:when>
                        <xsl:when test="$Datumslength = 6">
                            <xsl:value-of select="substring(., 1, 4)"/>
                            <xsl:text>-</xsl:text>
                            <xsl:value-of select="substring(., 5, 2)"/>
                            <xsl:text>-00</xsl:text>
                        </xsl:when>
                        <xsl:when test="$Datumslength = 8">
                            <xsl:value-of select="substring(., 1, 4)"/>
                            <xsl:text>-</xsl:text>
                            <xsl:value-of select="substring(., 5, 2)"/>
                            <xsl:text>-</xsl:text>
                            <xsl:value-of select="substring(., 7, 2)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:if test="not($Datumslength = 0)">
                                <xsl:text>ERROOR</xsl:text>
                            </xsl:if>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </Todesdatum>
    </xsl:template>

 

   <!--   <xsl:template match="Geburtsdatum_low">
        <xsl:choose>
            <xsl:when test=".='' and (number(preceding-sibling::Geburtsdatum) != number(preceding-sibling::Geburtsdatum))">
                <Geburtsdatum_low>
                    <xsl:value-of select="preceding-sibling::Geburtsdatum"/>
                </Geburtsdatum_low>
            </xsl:when>
            <xsl:otherwise>
                <Geburtsdatum_low>
                    <xsl:value-of select="."/>
                 </Geburtsdatum_low>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
        
        <xsl:template match="Todesdatum_low">
            <xsl:choose>
                <xsl:when test="(. = '' or empty(.)) and (number(preceding-sibling::Todesdatum) != number(preceding-sibling::Todesdatum))">
                    <Todesdatum_low>
                        <xsl:value-of select="preceding-sibling::Todesdatum"/>
                    </Todesdatum_low>
                </xsl:when>
                <xsl:otherwise>
                    <Todesdatum_low>
                        <xsl:value-of select="."/>
                    </Todesdatum_low>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:template>
        -->


  <!--      <xsl:template match="Todesdatum">
    <xsl:choose>
        <xsl:when test="number(.) = number(.)">
            <Todesdatum>
                <xsl:apply-templates/>
                </Todesdatum>
        </xsl:when>
        <xsl:otherwise>
            <Todesdatum/>
        </xsl:otherwise>
    </xsl:choose>
    
</xsl:template>
    
    <xsl:template match="Geburtsdatum">
        <xsl:choose>
            <xsl:when test="number(.) = number(.)">
                <Geburtsdatum>
                    <xsl:apply-templates/>
                </Geburtsdatum>
            </xsl:when>
            <xsl:otherwise>
                <Geburtsdatum/>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
-->
</xsl:stylesheet>
