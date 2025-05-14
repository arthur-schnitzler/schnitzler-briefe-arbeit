<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns="http://www.tei-c.org/ns/1.0" xmlns:tei="http://www.tei-c.org/ns/1.0"
   xmlns:fn="http://www.w3.org/2005/xpath-functions"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns:foo="whatever" exclude-result-prefixes="xs" version="2.0">
   <xsl:output method="xml" encoding="utf-8" indent="no"/>
   <!-- Globale Parameter -->
   <xsl:param name="persons" select="document('../indices/listperson.xml')"/>
   <xsl:key name="person-lookup" match="tei:person" use="substring-after(@xml:id, '#')"/>
   <!-- Identity template : copy all text nodes, elements and attributes -->
   <xsl:template match="@* | node()">
      <xsl:copy>
         <xsl:apply-templates select="@* | node()"/>
      </xsl:copy>
   </xsl:template>
   <!-- Ersetzt im übergegeben String die Umlaute mit ae, oe, ue etc. -->
   <xsl:function name="foo:umlaute-entfernen">
      <xsl:param name="umlautstring"/>
      <xsl:value-of
         select="replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace($umlautstring,'ä','ae'), 'ö', 'oe'), 'ü', 'ue'), 'ß', 'ss'), 'Ä', 'Ae'), 'Ü', 'Ue'), 'Ö', 'Oe'), 'é', 'e'), 'è', 'e'), 'É', 'E'), 'È', 'E'),'ò', 'o'), 'Č', 'C'), 'D’','D'), 'd’','D'), 'Ś', 'S'), '’', ' '), '&amp;', 'und'), 'ë', 'e'), '!', ''), 'č', 'c'), 'Ł', 'L')"
      />
   </xsl:function>
   <xsl:template match="root">
      <xsl:copy>
         <xsl:apply-templates select="TEI">
            <xsl:sort
               select="concat(foo:umlaute-entfernen(key('person-lookup', @bw, $persons)/tei:persName/tei:surname), ' ', foo:umlaute-entfernen(key('person-lookup', @bw, $persons)/tei:persName/tei:forename))"/>
            <xsl:sort select="@when"/>
            <xsl:sort select="xs:integer(@n)"/>
         </xsl:apply-templates>
      </xsl:copy>
   </xsl:template>
</xsl:stylesheet>
