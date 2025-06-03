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
    
    <xsl:template match="tei:back/tei:listPerson[not(child::*)]"/>
    <xsl:template match="tei:back/tei:listPlace[not(child::*)]"/>
    <xsl:template match="tei:back/tei:listOrg[not(child::*)]"/>
    <xsl:template match="tei:back/tei:listBibl[not(child::*)]"/>
    
    <xsl:template match="comment() | processing-instruction()" mode="copy-no-namespaces">
        <xsl:copy/>
    </xsl:template>
    
    <xsl:template match="tei:back/tei:listPerson[child::*]">
        <xsl:element name="listPerson" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:for-each select="distinct-values(tei:person/@xml:id)">
                <xsl:choose>
                    <xsl:when test=". = '2121' or .='pmb2121' or . = '#pmb2121'">
                        <xsl:element name="person" namespace="http://www.tei-c.org/ns/1.0">
                            <xsl:attribute name="xml:id">
                                <xsl:text>pmb2121</xsl:text>
                            </xsl:attribute>
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
                            <sex value="male"/>
                            <occupation ref="pmb90">Schriftsteller*in</occupation>
                            <occupation ref="pmb97">Mediziner*in</occupation>
                            <idno type="gnd">https://d-nb.info/gnd/118609807/</idno>
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
                                    <xsl:variable name="eintrag_inhalt"
                                        select="document($eintrag)/person"/> <xsl:apply-templates
                                            select="$eintrag_inhalt/persName[not(@type = 'loschen')] | $eintrag_inhalt/birth | $eintrag_inhalt/death | $eintrag_inhalt/sex | $eintrag_inhalt/occupation | $eintrag_inhalt/idno"
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
        <xsl:element name="listBibl" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:for-each select="distinct-values(tei:bibl/@xml:id)">
                <xsl:variable name="nummer" select="substring-after(., 'pmb')"/>
                <xsl:variable name="eintrag"
                    select="fn:escape-html-uri(concat('https://pmb.acdh.oeaw.ac.at/apis/tei/work/', $nummer))"
                    as="xs:string"/>
                <xsl:choose>
                    <xsl:when test="doc-available($eintrag)">
                        <xsl:element name="bibl" namespace="http://www.tei-c.org/ns/1.0">
                            <xsl:attribute name="xml:id">
                                <xsl:value-of select="concat('pmb', $nummer)"/>
                            </xsl:attribute>
                            <xsl:variable name="eintrag_inhalt" select="document($eintrag)/bibl"/> <xsl:apply-templates
                                select="$eintrag_inhalt/title[not(@type = 'loschen')] | $eintrag_inhalt/author | $eintrag_inhalt/date | $eintrag_inhalt/note[@type] | $eintrag_inhalt/idno"
                                mode="copy-no-namespaces"/>
                        </xsl:element>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:element name="error"> <xsl:attribute name="type">
                                <xsl:text>bibl</xsl:text>
                        </xsl:attribute>
                            <xsl:value-of select="$nummer"/>
                        </xsl:element>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="tei:back/tei:listPlace[child::*]">
        <xsl:element name="listPlace" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:for-each select="distinct-values(tei:place/@xml:id)">
                <xsl:variable name="nummer" select="replace(replace(., 'pmb', ''), '#', '')"/>
                <xsl:choose>
                    <xsl:when test="$nummer='50'">
                        <place xml:id="pmb50">
                            <placeName>Wien</placeName>
                            <placeName type="ort_fruherer-name">K.K. Reichshaupt- und Residenzstadt Wien</placeName>
                            <placeName type="alternative-name">Bécs</placeName>
                            <placeName type="alternative-name">Land Wien</placeName>
                            <placeName type="alternative-name">Vídeň</placeName>
                            <placeName type="alternative-name">Wenia</placeName>
                            <placeName type="alternative-name">Beč</placeName>
                            <placeName type="ort_fruherer-name">Vindobona</placeName>
                            <placeName type="alternative-name">Vienna</placeName>
                            <desc type="entity_type">A.ADM2</desc>
                            <desc type="entity_type_id">1135</desc>
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
                            <idno type="URL" subtype="geonames">https://sws.geonames.org/2761369/</idno>
                            <idno type="URL" subtype="d-nb">https://d-nb.info/gnd/4066009-6</idno>
                            <idno type="URL" subtype="schnitzler-bahr">https://schnitzler-bahr.acdh.oeaw.ac.at/pmb50.html</idno>
                            <idno type="URL" subtype="pmb">https://pmb.acdh.oeaw.ac.at/entity/50/</idno>
                            <idno type="URL" subtype="pmb">https://pmb.acdh.oeaw.ac.at/entity/2316/</idno>
                            <idno type="URL" subtype="pmb">https://pmb.acdh.oeaw.ac.at/entity/20954/</idno>
                            <idno type="URL" subtype="pmb">https://pmb.acdh.oeaw.ac.at/entity/65221/</idno>
                            <idno type="URL" subtype="pmb">https://pmb.acdh.oeaw.ac.at/entity/65223/</idno>
                            <idno type="URL" subtype="kraus">https://kraus.wienbibliothek.at/register/orte/pmb50</idno>
                            <idno type="URL" subtype="wikidata">http://www.wikidata.org/entity/Q1741</idno>
                            <idno type="URL" subtype="wikipedia">https://de.wikipedia.org/wiki/Wien</idno>
                            <idno type="URL" subtype="schnitzler-interviews">https://schnitzler-interviews.acdh.oeaw.ac.at/pmb50.html</idno>
                            <idno type="URL" subtype="geonames">https://sws.geonames.org/2761333/</idno>
                            <idno type="URL" subtype="pmb">https://pmb.acdh.oeaw.ac.at/entity/33999/</idno>
                            <idno type="URL" subtype="schnitzler-tagebuch">https://schnitzler-tagebuch.acdh.oeaw.ac.at/pmb50.html</idno>
                            <idno type="URL" subtype="schnitzler-briefe">https://schnitzler-briefe.acdh.oeaw.ac.at/pmb50.html</idno>
                            <note type="image">
                                <figure>
                                    <graphic url="https://iiif.onb.ac.at/images/AKON/AK117_016/016/full/,600/0/native.jpg"/>
                                </figure>
                            </note>
                        </place>
                    </xsl:when>
                    <xsl:otherwise><xsl:variable name="eintrag"
                    select="fn:escape-html-uri(concat('https://pmb.acdh.oeaw.ac.at/apis/tei/place/', $nummer))"
                    as="xs:string"/>
                <xsl:choose>
                    <xsl:when test="doc-available($eintrag)">
                        <xsl:apply-templates select="document($eintrag)" mode="copy-no-namespaces"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:element name="error"> <xsl:attribute name="type">
                                <xsl:text>place</xsl:text>
                        </xsl:attribute>
                            <xsl:value-of select="$nummer"/>
                        </xsl:element>
                    </xsl:otherwise>
                </xsl:choose></xsl:otherwise></xsl:choose>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="tei:back/tei:listOrg[child::*]">
        <xsl:element name="listOrg" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:for-each select="distinct-values(tei:org/@xml:id)">
                <xsl:variable name="nummer" select="substring-after(., 'pmb')"/>
                <xsl:variable name="eintrag"
                    select="fn:escape-html-uri(concat('https://pmb.acdh.oeaw.ac.at/apis/tei/org/', $nummer))"
                    as="xs:string"/>
                <xsl:choose>
                    <xsl:when test="doc-available($eintrag)">
                        <xsl:apply-templates select="document($eintrag)" mode="copy-no-namespaces"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:element name="error"> <xsl:attribute name="type">
                                <xsl:text>org</xsl:text>
                        </xsl:attribute>
                            <xsl:value-of select="$nummer"/>
                        </xsl:element>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>