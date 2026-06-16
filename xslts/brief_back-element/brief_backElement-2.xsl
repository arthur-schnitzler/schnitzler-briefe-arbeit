<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    version="3.0"
    exclude-result-prefixes="xs fn tei">
    
    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:output method="xml" indent="yes"/>
    
    <xsl:template match="*" mode="copy-no-namespaces">
        <xsl:element name="{local-name()}">
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates select="node()" mode="copy-no-namespaces"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="comment() | processing-instruction()" mode="copy-no-namespaces">
        <xsl:copy/>
    </xsl:template>
    
    <xsl:param name="listperson" select="document('../../python-temp/listperson.xml')"/>
    <xsl:param name="listbibl" select="document('../../python-temp/listbibl.xml')"/>
    <xsl:param name="listplace" select="document('../../python-temp/listplace.xml')"/>
    <xsl:param name="listorg" select="document('../../python-temp/listorg.xml')"/>
    <xsl:param name="listevent" select="document('../../python-temp/listevent.xml')"/>
    
    <xsl:key name="listperson-lookup" match="/tei:TEI[1]/tei:text[1]/tei:body[1]/tei:listPerson[1]/tei:person" use="@xml:id"/>
    <xsl:key name="listbibl-lookup" match="/tei:TEI[1]/tei:text[1]/tei:body[1]/tei:listBibl[1]/tei:bibl" use="@xml:id"/>
    <xsl:key name="listplace-lookup" match="/tei:TEI[1]/tei:text[1]/tei:body[1]/tei:listPlace[1]/tei:place" use="@xml:id"/>
    <xsl:key name="listorg-lookup" match="/tei:TEI[1]/tei:text[1]/tei:body[1]/tei:listOrg[1]/tei:org" use="@xml:id"/>
    <xsl:key name="listevent-lookup" match="/tei:TEI[1]/tei:text[1]/tei:body[1]/tei:listEvent[1]/tei:event" use="@xml:id"/>
    
    
    <xsl:template match="tei:back/tei:listPerson[not(child::*)]"/>
    <xsl:template match="tei:back/tei:listPlace[not(child::*)]"/>
    <xsl:template match="tei:back/tei:listOrg[not(child::*)]"/>
    <xsl:template match="tei:back/tei:listBibl[not(child::*)]"/>
    <xsl:template match="tei:back/tei:listEvent[not(child::*)]"/>
    
    
    <xsl:template match="tei:back/tei:listPerson[child::*]">
        <xsl:variable name="source-list" select="."/>
        <xsl:element name="listPerson" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:for-each select="distinct-values(tei:person/@xml:id)">
                <xsl:variable name="current-id" select="replace(replace(replace(., '#', ''), 'person__', ''), 'pmb', '')"/>
                <xsl:variable name="current-xml-id" select="."/>
                <xsl:variable name="ana-attribute" select="$source-list/tei:person[@xml:id = $current-xml-id]/@ana"/>
                <xsl:choose>
                    <xsl:when test="$current-id = '2121'">
                        <xsl:element name="person" namespace="http://www.tei-c.org/ns/1.0">
                            <xsl:attribute name="xml:id">
                                <xsl:text>pmb2121</xsl:text>
                            </xsl:attribute>
                            <xsl:if test="$ana-attribute">
                                <xsl:copy-of select="$ana-attribute"/>
                            </xsl:if>
                            <persName>
                                <surname>Schnitzler</surname>
                                <forename>Arthur</forename>
                            </persName>
                            <birth>
                                <date when="1862-05-15">15. 5. 1862</date>
                                <settlement key="pmb50">
                                    <placeName type="pref">Wien</placeName>
                                    <location>
                                        <geo>48,208333 16,373056</geo>
                                    </location>
                                </settlement>
                            </birth>
                            <death>
                                <date when="1931-10-21">21. 10. 1931</date>
                                <settlement key="pmb50">
                                    <placeName type="pref">Wien</placeName>
                                    <location>
                                        <geo>48,208333 16,373056</geo>
                                    </location>
                                </settlement>
                            </death>
                        </xsl:element>
                    </xsl:when>
                    <xsl:when test="key('listperson-lookup', concat('pmb', $current-id), $listperson)[1][child::*]">
                        <xsl:element name="person" namespace="http://www.tei-c.org/ns/1.0">
                            <xsl:copy-of select="key('listperson-lookup', concat('pmb', $current-id), $listperson)[1]/@xml:id"/>
                            <xsl:if test="$ana-attribute">
                                <xsl:copy-of select="$ana-attribute"/>
                            </xsl:if>
                            <xsl:variable name="entry" select="key('listperson-lookup', concat('pmb', $current-id), $listperson)[1]"/>
                            <xsl:copy-of select="$entry/tei:persName[1] | $entry/tei:birth | $entry/tei:death"/>
                        </xsl:element>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:variable name="nummer" select="substring-after(., 'pmb')"/>
                        <xsl:variable name="eintrag"
                            select="fn:escape-html-uri(concat('https://pmb.acdh.oeaw.ac.at/apis/tei/person/', $nummer))"
                            as="xs:string"/>
                        <xsl:choose>
                            <xsl:when test="doc-available($eintrag)">
                                <xsl:element name="person" namespace="http://www.tei-c.org/ns/1.0">
                                    <xsl:attribute name="xml:id">
                                        <xsl:value-of select="concat('pmb', $nummer)"/>
                                    </xsl:attribute>
                                    <xsl:if test="$ana-attribute">
                                        <xsl:copy-of select="$ana-attribute"/>
                                    </xsl:if>
                                    <xsl:variable name="eintrag_inhalt"
                                        select="document($eintrag)/person"/> <xsl:apply-templates
                                            select="$eintrag_inhalt/persName[not(@type = 'loschen')][1] | $eintrag_inhalt/birth | $eintrag_inhalt/death"
                                            mode="copy-no-namespaces"/>
                                </xsl:element>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:element name="error"> <xsl:attribute name="type">
                                        <xsl:text>person</xsl:text>
                                </xsl:attribute>
                                    <xsl:value-of select="$nummer"/>
                                </xsl:element>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="tei:back/tei:listBibl[child::*]">
        <xsl:variable name="source-list" select="."/>
        <xsl:element name="listBibl" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:for-each select="distinct-values(tei:bibl/@xml:id)">
                <xsl:variable name="current-id" select="replace(replace(., '#', ''), 'pmb', '')"/>
                <xsl:variable name="current-xml-id" select="."/>
                <xsl:variable name="ana-attribute" select="$source-list/tei:bibl[@xml:id = $current-xml-id]/@ana"/>
                <xsl:variable name="eintrag"
                    select="fn:escape-html-uri(concat('https://pmb.acdh.oeaw.ac.at/apis/tei/work/', $current-id))"
                    as="xs:string"/>
                <xsl:choose>
                    <xsl:when test="key('listbibl-lookup', concat('pmb', $current-id), $listbibl)[1][child::*]">
                        <xsl:element name="bibl" namespace="http://www.tei-c.org/ns/1.0">
                            <xsl:copy-of select="key('listbibl-lookup', concat('pmb', $current-id), $listbibl)[1]/@xml:id"/>
                            <xsl:if test="$ana-attribute">
                                <xsl:copy-of select="$ana-attribute"/>
                            </xsl:if>
                            <xsl:variable name="entry" select="key('listbibl-lookup', concat('pmb', $current-id), $listbibl)[1]"/>
                            <xsl:copy-of select="$entry/tei:title | $entry/tei:author"/>
                        </xsl:element>
                    </xsl:when>
                    <xsl:when test="doc-available($eintrag)">
                        <xsl:element name="bibl" namespace="http://www.tei-c.org/ns/1.0">
                            <xsl:attribute name="xml:id">
                                <xsl:value-of select="concat('pmb', $current-id)"/>
                            </xsl:attribute>
                            <xsl:if test="$ana-attribute">
                                <xsl:copy-of select="$ana-attribute"/>
                            </xsl:if>
                            <xsl:variable name="eintrag_inhalt" select="document($eintrag)/bibl"/>
                            <xsl:apply-templates
                                select="$eintrag_inhalt/title[not(@type = 'loschen')] | $eintrag_inhalt/author"
                                mode="copy-no-namespaces"/>
                        </xsl:element>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:element name="error"> <xsl:attribute name="type">
                                <xsl:text>bibl</xsl:text>
                        </xsl:attribute>
                            <xsl:value-of select="$current-id"/>
                        </xsl:element>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
    <xsl:template match="*[local-name()='author'][@key]" mode="copy-no-namespaces">
        <xsl:element name="author" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:copy-of select="@*[not(name()='key')]"/>
            <xsl:attribute name="ref">
                <xsl:value-of select="replace(@key, 'person__', 'pmb')"/>
            </xsl:attribute>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="tei:back/tei:listPlace[child::*]">
        <xsl:variable name="source-list" select="."/>
        <xsl:element name="listPlace" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:for-each select="distinct-values(tei:place/@xml:id)">
                <xsl:variable name="current-id" select="replace(replace(replace(., '#', ''), 'place__', ''), 'pmb', '')"/>
                <xsl:variable name="current-xml-id" select="."/>
                <xsl:variable name="ana-attribute" select="$source-list/tei:place[@xml:id = $current-xml-id]/@ana"/>
                <xsl:choose>
                    <xsl:when test="$current-id='50'">
                        <place xml:id="pmb50">
                            <xsl:if test="$ana-attribute">
                                <xsl:copy-of select="$ana-attribute"/>
                            </xsl:if>
                            <placeName>Wien</placeName>
                            <placeName type="ort_fruherer-name">K.K. Reichshaupt- und Residenzstadt Wien</placeName>
                            <placeName type="alternative-name">Bécs</placeName>
                            <placeName type="alternative-name">Land Wien</placeName>
                            <placeName type="alternative-name">Vídeň</placeName>
                            <placeName type="alternative-name">Wenia</placeName>
                            <placeName type="alternative-name">Beč</placeName>
                            <placeName type="ort_fruherer-name">Vindobona</placeName>
                            <placeName type="alternative-name">Vienna</placeName>
                            <location type="coords">
                                <geo>48,208333 16,373056</geo>
                            </location>
                            <location type="located_in_place">
                                <placeName ref="pmb41240">Österreich</placeName>
                                <geo>47,33333 13,33333</geo>
                            </location>
                            <location type="located_in_place">
                                <placeName ref="pmb235218">Windmühlhöhe</placeName>
                                <geo>48,24077 16,32092</geo>
                            </location>
                        </place>
                    </xsl:when>
                    <xsl:when test="key('listplace-lookup', concat('pmb', $current-id), $listplace)[1][child::*]">
                        <xsl:element name="place" namespace="http://www.tei-c.org/ns/1.0">
                            <xsl:copy-of select="key('listplace-lookup', concat('pmb', $current-id), $listplace)[1]/@xml:id"/>
                            <xsl:if test="$ana-attribute">
                                <xsl:copy-of select="$ana-attribute"/>
                            </xsl:if>
                            <xsl:variable name="entry" select="key('listplace-lookup', concat('pmb', $current-id), $listplace)[1]"/>
                            <xsl:copy-of select="$entry/tei:placeName | $entry/tei:location"/>
                        </xsl:element>
                    </xsl:when>
                    <xsl:otherwise><xsl:variable name="eintrag"
                    select="fn:escape-html-uri(concat('https://pmb.acdh.oeaw.ac.at/apis/tei/place/', $current-id))"
                    as="xs:string"/>
                <xsl:choose>
                    <xsl:when test="doc-available($eintrag)">
                        <xsl:variable name="api-content" select="document($eintrag)/*[local-name()='place']"/>
                        <xsl:choose>
                            <xsl:when test="$api-content/node()">
                                <xsl:element name="place" namespace="http://www.tei-c.org/ns/1.0">
                                    <xsl:attribute name="xml:id">
                                        <xsl:value-of select="concat('pmb', $current-id)"/>
                                    </xsl:attribute>
                                    <xsl:if test="$ana-attribute">
                                        <xsl:copy-of select="$ana-attribute"/>
                                    </xsl:if>
                                    <xsl:apply-templates select="$api-content/placeName | $api-content/location" mode="copy-no-namespaces"/>
                                </xsl:element>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:element name="error">
                                    <xsl:attribute name="type">
                                        <xsl:text>place-empty</xsl:text>
                                    </xsl:attribute>
                                    <xsl:value-of select="$current-id"/>
                                </xsl:element>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:element name="error"> <xsl:attribute name="type">
                                <xsl:text>place</xsl:text>
                        </xsl:attribute>
                            <xsl:value-of select="$current-id"/>
                        </xsl:element>
                    </xsl:otherwise>
                </xsl:choose></xsl:otherwise></xsl:choose>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="tei:back/tei:listOrg[child::*]">
        <xsl:variable name="source-list" select="."/>
        <xsl:element name="listOrg" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:for-each select="distinct-values(tei:org/@xml:id)">
                <xsl:variable name="current-id" select="replace(replace(., '#', ''), 'pmb', '')"/>
                <xsl:variable name="current-xml-id" select="."/>
                <xsl:variable name="ana-attribute" select="$source-list/tei:org[@xml:id = $current-xml-id]/@ana"/>
                <xsl:variable name="eintrag"
                    select="fn:escape-html-uri(concat('https://pmb.acdh.oeaw.ac.at/apis/tei/org/', $current-id))"
                    as="xs:string"/>
                <xsl:choose>
                    <xsl:when test="key('listorg-lookup', concat('pmb', $current-id), $listorg)[1][child::*]">
                        <xsl:element name="org" namespace="http://www.tei-c.org/ns/1.0">
                            <xsl:copy-of select="key('listorg-lookup', concat('pmb', $current-id), $listorg)[1]/@xml:id"/>
                            <xsl:if test="$ana-attribute">
                                <xsl:copy-of select="$ana-attribute"/>
                            </xsl:if>
                            <xsl:variable name="entry" select="key('listorg-lookup', concat('pmb', $current-id), $listorg)[1]"/>
                            <xsl:copy-of select="$entry/tei:orgName | $entry/tei:location"/>
                        </xsl:element>
                    </xsl:when>
                    <xsl:when test="doc-available($eintrag)">
                        <xsl:variable name="api-content" select="document($eintrag)/*[local-name()='org']"/>
                        <xsl:choose>
                            <xsl:when test="$api-content/node()">
                                <xsl:element name="org" namespace="http://www.tei-c.org/ns/1.0">
                                    <xsl:attribute name="xml:id">
                                        <xsl:value-of select="concat('pmb', $current-id)"/>
                                    </xsl:attribute>
                                    <xsl:if test="$ana-attribute">
                                        <xsl:copy-of select="$ana-attribute"/>
                                    </xsl:if>
                                    <xsl:apply-templates select="$api-content/orgName | $api-content/location" mode="copy-no-namespaces"/>
                                </xsl:element>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:element name="error">
                                    <xsl:attribute name="type">
                                        <xsl:text>org-empty</xsl:text>
                                    </xsl:attribute>
                                    <xsl:value-of select="$current-id"/>
                                </xsl:element>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:element name="error"> <xsl:attribute name="type">
                                <xsl:text>org</xsl:text>
                        </xsl:attribute>
                            <xsl:value-of select="$current-id"/>
                        </xsl:element>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="tei:back/tei:listEvent[child::*]">
        <xsl:variable name="source-list" select="."/>
        <xsl:element name="listEvent" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:for-each select="distinct-values(tei:event/@xml:id)">
                <xsl:variable name="current-id" select="replace(replace(., '#', ''), 'pmb', '')"/>
                <xsl:variable name="current-xml-id" select="."/>
                <xsl:variable name="ana-attribute" select="$source-list/tei:event[@xml:id = $current-xml-id]/@ana"/>
                <xsl:variable name="eintrag"
                    select="fn:escape-html-uri(concat('https://pmb.acdh.oeaw.ac.at/apis/tei/event/', $current-id))"
                    as="xs:string"/>
                <xsl:choose>
                    <xsl:when test="key('listevent-lookup', concat('pmb', $current-id), $listevent)[1][child::*]">
                        <xsl:element name="event" namespace="http://www.tei-c.org/ns/1.0">
                            <xsl:copy-of select="key('listevent-lookup', concat('pmb', $current-id), $listevent)[1]/@xml:id"/>
                            <xsl:if test="$ana-attribute">
                                <xsl:copy-of select="$ana-attribute"/>
                            </xsl:if>
                            <xsl:variable name="entry" select="key('listevent-lookup', concat('pmb', $current-id), $listevent)[1]"/>
                            <xsl:copy-of select="$entry/tei:eventName | $entry/tei:listPlace"/>
                        </xsl:element>
                    </xsl:when>
                    <xsl:when test="doc-available($eintrag)">
                        <xsl:element name="event" namespace="http://www.tei-c.org/ns/1.0">
                            <xsl:attribute name="xml:id">
                                <xsl:value-of select="concat('pmb', $current-id)"/>
                            </xsl:attribute>
                            <xsl:if test="$ana-attribute">
                                <xsl:copy-of select="$ana-attribute"/>
                            </xsl:if>
                            <xsl:variable name="ev" select="document($eintrag)/*[local-name()='event']"/>
                            <xsl:apply-templates select="$ev/eventName | $ev/listPlace" mode="copy-no-namespaces"/>
                        </xsl:element>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:element name="error"> <xsl:attribute name="type">
                                <xsl:text>event</xsl:text>
                        </xsl:attribute>
                            <xsl:value-of select="$current-id"/>
                        </xsl:element>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
    
    
</xsl:stylesheet>