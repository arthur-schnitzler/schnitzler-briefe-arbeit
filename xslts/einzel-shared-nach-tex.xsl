<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions"
   xmlns:foo="whatever" xmlns:tei="http://www.tei-c.org/ns/1.0" version="3.0"
   xmlns:map="http://www.w3.org/2005/xpath-functions/map">
   <xsl:output method="text"/>
   <xsl:import href="tex_date-format.xsl"/>
   <xsl:strip-space elements="*"/>
   <!-- subst root tei:persName address body div sourceDesc physDesc witList msIdentifier fileDesc teiHeader correspDesc correspAction date witnessdate -->
   <!-- Globale Parameter -->
   <xsl:param name="persons" select="descendant::tei:back/tei:listPerson"/>
   <xsl:param name="works" as="node()" select="descendant::tei:back/tei:listBibl"/>
   <xsl:param name="orgs" select="descendant::tei:back/tei:listOrg"/>
   <xsl:param name="places" select="descendant::tei:back/tei:listPlace" as="node()"/>
   <xsl:param name="placeTypes" select="document('../indices/utils/placeTypes.xml')" as="node()"/>
   <xsl:param name="partOf" select="document('./indices/utils/partOf.xml')" as="node()"/>
   <xsl:param name="events" select="//tei:back/tei:listEvent"/>
   <!--<xsl:param name="sigle" select="document('../indices/siglen.xml')"/>-->
   <xsl:key name="person-lookup" match="tei:person" use="@xml:id"/>
   <xsl:key name="work-lookup" match="tei:bibl" use="@xml:id"/>
   <xsl:key name="org-lookup" match="tei:org" use="@xml:id"/>
   <xsl:key name="place-lookup" match="tei:place" use="@xml:id"/>
   <xsl:key name="event-lookup" match="tei:event" use="@xml:id"/>
   <xsl:key name="sigle-lookup" match="tei:row" use="tei:siglekey"/>
   <xsl:key name="placeType-lookup" match="*:item" use="*:abbreviation"/>
   <!-- Funktionen -->
   <!-- Ersetzt im übergegeben String die Umlaute mit ae, oe, ue etc. -->
   <xsl:function name="foo:umlaute-entfernen" as="xs:string">
      <xsl:param name="umlautstring" as="xs:string"/>
      <!-- Map für Zeichen-Ersetzungen -->
      <xsl:variable name="ersetzungen" as="map(xs:string, xs:string)" select="map {
         'ä': 'ae', 'ö': 'oe', 'ü': 'ue', 'ß': 'ss',
         'Ä': 'Ae', 'Ü': 'Ue', 'Ö': 'Oe',
         'é': 'e', 'è': 'e', 'É': 'E', 'È': 'E', 'ë': 'e',
         'ò': 'o', 'Č': 'C', 'č': 'c', 
         'Ď': 'D', 'ď': 'd', 'Ś': 'S', 'Ł': 'L',
         '&#8217;': ' ', '&amp;': 'und', '!': ''
         }"/>
      <!-- Alle Zeichen in einem Durchgang ersetzen -->
      <xsl:value-of select="
            fold-left(
            map:keys($ersetzungen),
            $umlautstring,
            function ($text, $zeichen) {
               replace($text, fn:escape-html-uri($zeichen), map:get($ersetzungen, $zeichen))
            }
            )"/>
   </xsl:function>
   <!-- Ersetzt im übergegeben String die Kaufmannsund -->
   <xsl:function name="foo:sonderzeichen-ersetzen">
      <xsl:param name="sonderzeichen" as="xs:string"/>
      <xsl:value-of
         select="replace(replace($sonderzeichen, '&amp;', '{\\kaufmannsund} '), '!', '{\\rufezeichen}')"
      />
   </xsl:function>
   <!-- Gibt zwei Werte zurück: Den Indexeintrag zum sortieren und den, wie er erscheinen soll -->
   <xsl:function name="foo:index-sortiert">
      <xsl:param name="index-sortieren" as="xs:string"/>
      <xsl:param name="shape" as="xs:string"/>
      <!-- werte sc, it, bf -->
      <xsl:value-of select="foo:umlaute-entfernen(foo:werk-um-artikel-kuerzen($index-sortieren))"/>
      <xsl:text>@</xsl:text>
      <xsl:choose>
         <xsl:when test="$shape = 'sc'">
            <xsl:text>\textsc{</xsl:text>
            <xsl:value-of select="foo:sonderzeichen-ersetzen($index-sortieren)"/>
            <xsl:text>}</xsl:text>
         </xsl:when>
         <xsl:when test="$shape = 'it'">
            <xsl:text>\emph{</xsl:text>
            <xsl:value-of select="foo:sonderzeichen-ersetzen($index-sortieren)"/>
            <xsl:text>}</xsl:text>
         </xsl:when>
         <xsl:when test="$shape = 'bf'">
            <xsl:text>\textbf{</xsl:text>
            <xsl:value-of select="foo:sonderzeichen-ersetzen($index-sortieren)"/>
            <xsl:text>}</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="foo:sonderzeichen-ersetzen($index-sortieren)"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <xsl:function name="foo:date-iso">
      <xsl:param name="iso-datum" as="xs:string"/>
      <xsl:variable name="iso-year" as="xs:string?" select="tokenize($iso-datum, '-')[1]"/>
      <xsl:variable name="iso-month" as="xs:string?" select="tokenize($iso-datum, '-')[2]"/>
      <xsl:variable name="iso-day" as="xs:string?" select="tokenize($iso-datum, '-')[last()]"/>
      <xsl:choose>
         <xsl:when test="$iso-day = '00' and $iso-month = '00'">
            <xsl:value-of select="number($iso-year)"/>
         </xsl:when>
         <xsl:when test="$iso-day = '00'">
            <xsl:value-of select="foo:Monatsname($iso-month)"/>
            <xsl:text> </xsl:text>
            <xsl:value-of select="$iso-year"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="number($iso-day)"/>
            <xsl:text>.&#8239;</xsl:text>
            <xsl:value-of select="number($iso-month)"/>
            <xsl:text>.&#8239;</xsl:text>
            <xsl:value-of select="number($iso-year)"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <xsl:function name="foo:lebensdaten-setzen">
      <xsl:param name="kGeburtsTodesDatum" as="xs:string?"/>
      <xsl:param name="kGeburtsTodesDatum_low" as="xs:string?"/>
      <xsl:param name="kGeburtsTodesOrt" as="xs:string?"/>
      <xsl:choose>
         <xsl:when test="empty($kGeburtsTodesDatum) or $kGeburtsTodesDatum = ''">
            <xsl:choose>
               <xsl:when test="empty($kGeburtsTodesDatum_low) or $kGeburtsTodesDatum_low = ''"/>
               <xsl:otherwise>
                  <xsl:value-of select="normalize-space($kGeburtsTodesDatum_low)"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:when>
         <xsl:otherwise>
            <xsl:choose>
               <xsl:when
                  test="starts-with($kGeburtsTodesDatum, '-') and string-length($kGeburtsTodesDatum) &lt; 6">
                  <xsl:value-of
                     select="foo:date-iso(normalize-space(substring(concat($kGeburtsTodesDatum, '-00-00'), 2)))"/>
                  <xsl:text> v.&#8239;u.&#8239;Z.</xsl:text>
               </xsl:when>
               <xsl:when test="starts-with($kGeburtsTodesDatum, '-')">
                  <xsl:value-of
                     select="foo:date-iso(normalize-space(substring(concat($kGeburtsTodesDatum, '-00-00'), 2)))"/>
                  <xsl:text> v.&#8239;u.&#8239;Z.</xsl:text>
               </xsl:when>
               <xsl:when test="(string-length($kGeburtsTodesDatum) &lt; 5)">
                  <xsl:value-of
                     select="foo:date-iso(normalize-space(concat($kGeburtsTodesDatum, '-00-00')))"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="foo:date-iso($kGeburtsTodesDatum)"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:choose>
         <xsl:when test="$kGeburtsTodesOrt = ''"/>
         <xsl:otherwise>
            <xsl:text> </xsl:text>
            <xsl:value-of select="normalize-space(replace($kGeburtsTodesOrt, '/', '{\slash}'))"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <!-- Diese Funktion setzt den Inhalt eines Index-Eintrags einer Person. Übergeben wird nur der key -->
   <xsl:function name="foo:person-fuer-index">
      <xsl:param name="xkey" as="xs:string"/>
      <xsl:variable name="indexkey" select="key('person-lookup', $xkey, $persons)" as="node()?"/>
      <xsl:variable name="kName" as="xs:string?"
         select="normalize-space($indexkey/tei:persName/tei:surname)"/>
      <xsl:variable name="kforename" as="xs:string?"
         select="normalize-space($indexkey/tei:persName/tei:forename)"/>
      <xsl:variable name="kZusatz" as="xs:string?" select="normalize-space($indexkey/Zusatz)"/>
      <xsl:variable name="kBeruf" as="xs:boolean">
         <xsl:choose>
            <xsl:when
               test="$indexkey/tei:occupation[1] and not(starts-with($indexkey/tei:persName/tei:surname, '??'))">
               <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="false()"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:variable name="kTodesort" as="xs:string?">
         <xsl:choose>
            <xsl:when
               test="$indexkey/tei:death[1]/tei:placeName[not(@type) or @type = 'pref']/tei:settlement">
               <xsl:value-of
                  select="fn:normalize-space($indexkey/tei:death[1]/tei:placeName[not(@type) or @type = 'pref']/tei:settlement)"
               />
            </xsl:when>
            <xsl:when test="$indexkey/tei:death[1]/tei:placeName[@type = 'deportation']">
               <xsl:value-of
                  select="concat('deportiert ', fn:normalize-space($indexkey/tei:death[1]/tei:placeName[1]/tei:settlement))"
               />
            </xsl:when>
            <xsl:when test="$indexkey/tei:death[1]/tei:placeName[@type = 'burial']">
               <xsl:value-of
                  select="concat('beerdigt ', fn:normalize-space($indexkey/tei:death[1]/tei:placeName[1]/tei:settlement))"
               />
            </xsl:when>
            <xsl:when
               test="$indexkey/tei:death[1]/tei:settlement[1]/tei:placeName[not(@type) or @type = 'pref']">
               <xsl:value-of
                  select="fn:normalize-space($indexkey/tei:death[1]/tei:settlement[1]/tei:placeName[not(@type) or @type = 'pref'])"
               />
            </xsl:when>
            <xsl:when test="$indexkey/tei:death[1]/tei:settlement[1]/tei:placeName[@type = 'deportation']">
               <xsl:value-of
                  select="concat('deportiert ', fn:normalize-space($indexkey/tei:death[1]/tei:settlement[1]/tei:placeName))"
               />
            </xsl:when>
            <xsl:when test="$indexkey/tei:death[1]/tei:settlement[1]/tei:placeName[@type = 'burial']">
               <xsl:value-of
                  select="concat('beerdigt ', fn:normalize-space($indexkey/tei:death[1]/tei:settlement[1]/tei:placeName))"
               />
            </xsl:when>
         </xsl:choose>
      </xsl:variable>
      <xsl:variable name="kGeburtsort" as="xs:string?">
         <xsl:choose>
            <xsl:when test="$indexkey/tei:birth[1]/tei:placeName[1]/tei:settlement">
               <xsl:value-of select="$indexkey/tei:birth[1]/tei:placeName[1]/tei:settlement"/>
            </xsl:when>
            <xsl:when test="$indexkey/tei:birth[1]/tei:settlement[1]/tei:placeName">
               <xsl:value-of select="$indexkey/tei:birth[1]/tei:settlement[1]/tei:placeName"/>
            </xsl:when>
         </xsl:choose>
      </xsl:variable>
      <xsl:variable name="birth_day" as="xs:string?">
         <xsl:choose>
            <xsl:when test="string-length($kGeburtsort) &gt; 0">
               <xsl:value-of
                  select="concat(foo:date-translate($indexkey[1]/tei:birth[1]/tei:date[1]/text()), ' ', $kGeburtsort)"
               />
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of
                  select="foo:date-translate($indexkey[1]/tei:birth[1]/tei:date[1]/text())"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:variable name="ebenda" as="xs:boolean"
         select="$kGeburtsort = $kTodesort and fn:string-length($kGeburtsort) &gt; 1"/>
      <xsl:variable name="death_day" as="xs:string?">
         <xsl:choose>
            <xsl:when test="$ebenda">
               <xsl:value-of
                  select="concat(foo:date-translate($indexkey[1]/tei:death[1]/tei:date[1]/text()), ' ebd.')"
               />
            </xsl:when>
            <xsl:when test="string-length($kTodesort) &gt; 0">
               <xsl:value-of
                  select="concat(foo:date-translate($indexkey[1]/tei:death[1]/tei:date[1]/text()), ' ', $kTodesort)"
               />
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of
                  select="foo:date-translate($indexkey[1]/tei:death[1]/tei:date[1]/text())"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:variable name="lebensdaten" as="xs:string?">
         <xsl:choose>
            <xsl:when test="contains($birth_day, 'Jh.')">
               <xsl:value-of select="$birth_day"/>
            </xsl:when>
            <xsl:when test="string-length($birth_day) &gt; 1 and string-length($death_day) &gt; 1">
               <xsl:value-of select="concat($birth_day, ' – ', ($death_day))"/>
            </xsl:when>
            <xsl:when test="string-length($birth_day) &gt; 1">
               <xsl:value-of select="concat('*~', $birth_day)"/>
            </xsl:when>
            <xsl:when test="string-length($death_day) &gt; 1">
               <xsl:value-of select="concat('†~', $death_day)"/>
            </xsl:when>
         </xsl:choose>
      </xsl:variable>
      <xsl:choose>
         <xsl:when test="not($kforename = '') and not($kName = '')">
            <xsl:value-of
               select="foo:umlaute-entfernen(concat($kName, ', ', $kforename, ' ', $lebensdaten))"/>
            <xsl:text>@</xsl:text>
            <xsl:text>\textsc{</xsl:text>
            <xsl:value-of select="foo:sonderzeichen-ersetzen(concat($kName, ', ', $kforename))"/>
            <xsl:text>}</xsl:text>
         </xsl:when>
         <xsl:when test="not($kforename = '') and $kName = ''">
            <xsl:value-of select="foo:umlaute-entfernen(concat($kforename, ' ', $lebensdaten))"/>
            <xsl:text>@</xsl:text>
            <xsl:text>\textsc{</xsl:text>
            <xsl:value-of select="foo:sonderzeichen-ersetzen($kforename)"/>
            <xsl:text>}</xsl:text>
         </xsl:when>
         <xsl:when test="$kforename = '' and not($kName = '')">
            <xsl:value-of select="foo:umlaute-entfernen(concat($kName, ' ', $lebensdaten))"/>
            <xsl:text>@</xsl:text>
            <xsl:text>\textsc{</xsl:text>
            <xsl:value-of select="foo:sonderzeichen-ersetzen($kName)"/>
            <xsl:text>}</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>\textcolor{red}{\textsuperscript{XXXX indx1}}</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="not($kZusatz = '')">
         <xsl:text>, </xsl:text>
         <xsl:value-of select="$kZusatz"/>
         <xsl:text/>
      </xsl:if>
      <xsl:if test="fn:string-length($lebensdaten) &gt; 1">
         <xsl:text> (</xsl:text>
         <xsl:value-of select="$lebensdaten"/>
         <xsl:text>)</xsl:text>
      </xsl:if>
      <xsl:if test="$kBeruf and not($kName = '??')">
         <xsl:variable name="gender" as="xs:boolean?">
            <xsl:choose>
               <xsl:when test="$indexkey/tei:sex/@value = 'male'">
                  <xsl:value-of select="false()"/>
               </xsl:when>
               <xsl:when test="$indexkey/tei:sex/@value = 'female'">
                  <xsl:value-of select="true()"/>
               </xsl:when>
               <xsl:otherwise/>
            </xsl:choose>
         </xsl:variable>
         <xsl:text>, \emph{</xsl:text>
         <xsl:for-each select="$indexkey/tei:occupation">
            <xsl:if test="fn:position() &lt; 4">
               <!-- Nur drei Berufe aufnehmen -->
               <xsl:variable name="berufstring"
                  select="normalize-space(tokenize(., ' >> ')[last()])"/>
               <xsl:choose>
                  <xsl:when test="not($gender = true() or $gender = false())">
                     <xsl:value-of select="fn:normalize-space(.)"/>
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:value-of select="foo:professionMitGender($berufstring, $gender)"/>
                  </xsl:otherwise>
               </xsl:choose>
               <xsl:if test="not(fn:position() = last()) and not(fn:position() = 3)">
                  <!-- 2. Teil von nur drei Berufe -->
                  <xsl:text>, </xsl:text>
               </xsl:if>
            </xsl:if>
         </xsl:for-each>
         <xsl:text>}</xsl:text>
         <xsl:text/>
      </xsl:if>
   </xsl:function>
   <xsl:function name="foo:professionMitGender">
      <xsl:param name="professionstring" as="xs:string"/>
      <xsl:param name="isFemale" as="xs:boolean"/>
      <xsl:choose>
         <xsl:when test="$isFemale">
            <xsl:value-of select="tokenize($professionstring, '/')[2]"/>
         </xsl:when>
         <xsl:when test="not($isFemale)">
            <xsl:value-of select="tokenize($professionstring, '/')[1]"/>
         </xsl:when>
      </xsl:choose>
   </xsl:function>
   <xsl:function name="foo:person-in-index">
      <xsl:param name="indexkey" as="xs:string?"/>
      <xsl:param name="endung" as="xs:string"/>
      <xsl:param name="endung-setzen" as="xs:boolean"/>
      <xsl:if test="not($indexkey = '')">
         <xsl:text>\pwindex{</xsl:text>
         <xsl:choose>
            <!-- Sonderregel für anonym -->
            <xsl:when test="$indexkey = '' or empty($indexkey)">
               <xsl:text>--@Nicht ermittelte Verfasser</xsl:text>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="foo:person-fuer-index(replace($indexkey, '#', ''))"/>
            </xsl:otherwise>
         </xsl:choose>
         <xsl:if test="$endung-setzen">
            <xsl:value-of select="$endung"/>
         </xsl:if>
      </xsl:if>
   </xsl:function>
   <xsl:function name="foo:werk-um-artikel-kuerzen">
      <xsl:param name="string" as="xs:string?"/>
      <xsl:choose>
         <xsl:when test="starts-with($string, 'Der ')">
            <xsl:value-of select="substring-after($string, 'Der ')"/>
         </xsl:when>
         <xsl:when test="starts-with($string, 'Das ')">
            <xsl:value-of select="substring-after($string, 'Das ')"/>
         </xsl:when>
         <xsl:when test="starts-with($string, 'Die ')">
            <xsl:value-of select="substring-after($string, 'Die ')"/>
         </xsl:when>
         <xsl:when test="starts-with($string, 'The ')">
            <xsl:value-of select="substring-after($string, 'The ')"/>
         </xsl:when>
         <xsl:when test="starts-with($string, 'Ein ')">
            <xsl:value-of select="substring-after($string, 'Ein ')"/>
         </xsl:when>
         <xsl:when test="starts-with($string, 'An ')">
            <xsl:choose>
               <xsl:when
                  test="starts-with($string, 'An die') or starts-with($string, 'An ein') or starts-with($string, 'An den') or starts-with($string, 'An das')">
                  <xsl:value-of select="$string"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="substring-after($string, 'An ')"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:when>
         <xsl:when test="starts-with($string, 'A ')">
            <xsl:value-of select="substring-after($string, 'A ')"/>
         </xsl:when>
         <xsl:when test="starts-with($string, 'La ')">
            <xsl:value-of select="substring-after($string, 'La ')"/>
         </xsl:when>
         <xsl:when test="starts-with($string, 'Il ')">
            <xsl:value-of select="substring-after($string, 'Il ')"/>
         </xsl:when>
         <xsl:when test="starts-with($string, 'Les ')">
            <xsl:value-of select="substring-after($string, 'Les ')"/>
         </xsl:when>
         <xsl:when test="starts-with($string, 'L’')">
            <xsl:value-of select="substring-after($string, 'L’')"/>
         </xsl:when>
         <xsl:when test="starts-with($string, '‹s')">
            <xsl:value-of select="substring-after($string, '‹s')"/>
         </xsl:when>
         <xsl:when test="starts-with($string, '‹s')">
            <xsl:value-of select="substring-after($string, '‹s')"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="$string"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <xsl:function name="foo:werk-kuerzen">
      <xsl:param name="string" as="xs:string?"/>
      <xsl:choose>
         <xsl:when test="substring($string, 1, 1) = '»'">
            <xsl:value-of select="foo:werk-kuerzen(substring($string, 2))"/>
         </xsl:when>
         <xsl:when test="substring($string, 1, 1) = '['">
            <xsl:choose>
               <!-- Das unterscheidet ob Autorangabe [H. B.:] oder unechter Titel [Jugend in Wien] -->
               <xsl:when test="contains($string, ':]')">
                  <xsl:value-of select="foo:werk-kuerzen(substring-after($string, ':] '))"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="foo:werk-kuerzen(substring($string, 2))"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="foo:umlaute-entfernen(foo:werk-um-artikel-kuerzen($string))"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <!-- <xsl:if test="tokenize(">
        
      </xsl:if>  -->
   <xsl:function name="foo:werk-metadaten-in-index">
      <xsl:param name="typ" as="xs:string?"/>
      <xsl:param name="erscheinungsdatum" as="xs:string?"/>
      <xsl:param name="auffuehrung" as="xs:string?"/>
      <xsl:choose>
         <xsl:when test="$erscheinungsdatum != '' or $typ != ''">
            <!--<xsl:when test="$erscheinungsdatum!='' or $typ!='' or $auffuehrung!=''">-->
            <xsl:text> {[}</xsl:text>
         </xsl:when>
      </xsl:choose>
      <xsl:if test="$typ != ''">
         <xsl:value-of select="normalize-space($typ)"/>
      </xsl:if>
      <xsl:if test="$erscheinungsdatum != ''">
         <xsl:if test="$typ != ''">
            <xsl:text>, </xsl:text>
         </xsl:if>
         <xsl:value-of select="normalize-space(foo:date-translate($erscheinungsdatum))"/>
      </xsl:if>
      <!--<xsl:if test="$auffuehrung!=''">
      <xsl:if test="$typ!='' or $erscheinungsdatum!=''">
         <xsl:text>, </xsl:text>
      </xsl:if>
      <xsl:value-of select="normalize-space(foo:date-translate($auffuehrung))"/>
   </xsl:if>-->
      <xsl:choose>
         <xsl:when test="$erscheinungsdatum != '' or $typ != ''">
            <!--<xsl:when test="$erscheinungsdatum!='' or $typ!='' or $auffuehrung!=''">-->
            <xsl:text>{]}</xsl:text>
         </xsl:when>
      </xsl:choose>
   </xsl:function>
   <xsl:function name="foo:werk-in-index">
      <xsl:param name="first" as="xs:string"/>
      <xsl:param name="endung" as="xs:string"/>
      <xsl:param name="author-zaehler" as="xs:integer"/>
      <xsl:variable name="work-entry" select="key('work-lookup', $first, $works)"/>
      <xsl:choose>
         <xsl:when test="$first = '' or empty($first)">
            <xsl:text>\textcolor{red}{\textsuperscript{\textbf{KEY}}}</xsl:text>
         </xsl:when>
         <xsl:when test="not(starts-with($first, 'pmb'))">
            <xsl:text>\textcolor{red}{FEHLER2}</xsl:text>
         </xsl:when>
         <xsl:when test="empty($work-entry)">
            <xsl:text>\textcolor{red}{XXXX}</xsl:text>
         </xsl:when>
         <xsl:when
            test="$work-entry/tei:author[@role = 'author' or @role = 'hat-geschaffen'][$author-zaehler]">
            <xsl:variable name="author-ref"
               select="$work-entry/tei:author[@role = 'author' or @role = 'hat-geschaffen'][$author-zaehler]/@ref"/>
            <xsl:value-of select="foo:person-in-index(concat('#', $author-ref), $endung, false())"/>
            <xsl:text>!</xsl:text>
         </xsl:when>
         <xsl:when test="$work-entry/tei:author[@role = 'abbreviated-name']">
            <xsl:variable name="author-ref"
               select="substring-after($work-entry/tei:author[@role = 'abbreviated-name'][$author-zaehler]/tei:idno[@type = 'pmb'], '#')"/>
            <xsl:value-of select="foo:person-in-index($author-ref, $endung, false())"/>
            <xsl:text>!</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>\pwindex{</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <!-- Sonderbehandlung für Bahrs Tagebuch-Kolumne -->
      <xsl:choose>
         <xsl:when
            test="$work-entry/tei:author/@ref = '#pmb10815' and starts-with($work-entry/tei:title, 'Tagebuch') and not(normalize-space($work-entry/tei:title) = 'Tagebuch')">
            <xsl:text>Tagebuch@\strich\emph{Tagebuch}!</xsl:text>
            <xsl:choose>
               <xsl:when test="starts-with($work-entry/tei:title, 'Tagebuch. ')">
                  <xsl:value-of select="tokenize($work-entry/Bibliografie, ' ')[last()]"/>
                  <xsl:choose>
                     <xsl:when
                        test="string-length(tokenize($work-entry/Bibliografie, ' ')[last() - 1]) = 2">
                        <xsl:text>0</xsl:text>
                     </xsl:when>
                  </xsl:choose>
                  <xsl:value-of select="tokenize($work-entry/Bibliografie, ' ')[last() - 1]"/>
                  <xsl:choose>
                     <xsl:when
                        test="string-length(tokenize($work-entry/Bibliografie, ' ')[last() - 2]) = 2">
                        <xsl:text>0</xsl:text>
                     </xsl:when>
                  </xsl:choose>
                  <xsl:value-of select="tokenize($work-entry/Bibliografie, ' ')[last() - 2]"/>
                  <xsl:value-of select="$work-entry/tei:title"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:text>0</xsl:text>
                  <xsl:value-of select="$work-entry/tei:title"/>
               </xsl:otherwise>
            </xsl:choose>
            <xsl:text>@\emph{</xsl:text>
            <xsl:choose>
               <xsl:when test="starts-with($work-entry/tei:title, 'Tagebuch. ')">
                  <xsl:value-of select="substring-after($work-entry/tei:title, 'Tagebuch. ')"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:choose>
                     <xsl:when test="starts-with($work-entry/tei:title, 'Tagebuch ')">
                        <xsl:value-of select="substring-after($work-entry/tei:title, 'Tagebuch ')"/>
                     </xsl:when>
                     <xsl:otherwise>
                        <xsl:text>XXXX </xsl:text>
                     </xsl:otherwise>
                  </xsl:choose>
               </xsl:otherwise>
            </xsl:choose>
            <xsl:text>}</xsl:text>
            <xsl:value-of
               select="foo:werk-metadaten-in-index($work-entry/Typ, $work-entry/Erscheinungsdatum, '')"
            />
         </xsl:when>
         <!--<xsl:when test="not(normalize-space($work-entry/Zyklus) = '')">
            <xsl:value-of select="foo:werk-kuerzen($zyklus-entry/Titel)"/>
            <xsl:value-of select="($zyklus-entry/Erscheinungsdatum)"/>
            <xsl:value-of select="($zyklus-entry/Typ)"/>
            <xsl:text>@\strich\emph{</xsl:text>
            <xsl:apply-templates select="normalize-space(foo:sonderzeichen-ersetzen($zyklus-entry/Titel))"/>
            <xsl:text>}</xsl:text>
            <xsl:value-of select="foo:werk-metadaten-in-index($zyklus-entry/Typ, $zyklus-entry/Erscheinungsdatum, $zyklus-entry/Aufführung)"/>
            <xsl:text>!</xsl:text>
            <xsl:value-of select="substring-after($work-entry/Zyklus, ',')"/>
            <xsl:apply-templates select="foo:werk-kuerzen($work-entry/tei:title)"/>
            <xsl:text>@\strich\emph{</xsl:text>
            <xsl:choose>
               <xsl:when test="$work-entry/Autor = 'A002003' and contains($work-entry/tei:title, 'O. V.:')">
                  <xsl:apply-templates select="normalize-space(substring(foo:sonderzeichen-ersetzen($work-entry/tei:title), 9))"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:apply-templates select="normalize-space(foo:sonderzeichen-ersetzen($work-entry/tei:title))"/>
               </xsl:otherwise>
            </xsl:choose>
            <xsl:text>}</xsl:text>
            <xsl:value-of select="foo:werk-metadaten-in-index($work-entry/Typ, $work-entry/Erscheinungsdatum, $work-entry/Aufführung)"/>
         </xsl:when>-->
         <xsl:otherwise>
            <xsl:apply-templates select="foo:werk-kuerzen($work-entry/tei:title[1])"/>
            <!--<xsl:value-of select="($work-entry/Bibliografie)"/>-->
            <xsl:if
               test="not(empty($work-entry/Erscheinungsdatum) or $work-entry/Erscheinungsdatum = '')">
               <xsl:value-of
                  select="normalize-space(foo:date-translate($work-entry/Erscheinungsdatum))"/>
            </xsl:if>
            <xsl:value-of select="($work-entry/Typ)"/>
            <xsl:choose>
               <xsl:when test="$work-entry/tei:author and not($author-zaehler = 0)">
                  <xsl:text>@\strich\emph{</xsl:text>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:text>@\emph{</xsl:text>
               </xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
               <xsl:when
                  test="$work-entry/tei:author/@xml:id = 'A002003' and contains($work-entry/tei:title[1], 'O. V.:')">
                  <xsl:apply-templates
                     select="normalize-space(substring(foo:sonderzeichen-ersetzen($work-entry/tei:title[1]), 9))"
                  />
               </xsl:when>
               <xsl:otherwise>
                  <xsl:apply-templates
                     select="normalize-space(foo:sonderzeichen-ersetzen($work-entry/tei:title[1]))"
                  />
               </xsl:otherwise>
            </xsl:choose>
            <xsl:text>}</xsl:text>
            <xsl:value-of
               select="foo:werk-metadaten-in-index($work-entry/Typ, $work-entry/Erscheinungsdatum, $work-entry/Aufführung)"
            />
         </xsl:otherwise>
      </xsl:choose>
      <xsl:value-of select="$endung"/>
   </xsl:function>
   <xsl:function name="foo:event-in-index">
      <xsl:param name="first" as="xs:string"/>
      <xsl:param name="endung" as="xs:string"/>
      <xsl:variable name="event-entry" select="key('event-lookup', ($first), $events)"/>
      <xsl:variable name="ort" select="$event-entry/tei:listPlace[1]/tei:place[1]/tei:placeName[1]"/>
      <xsl:variable name="typ" select="$event-entry/tei:eventName/@n"/>
      <xsl:choose>
         <xsl:when test="string-length($event-entry/tei:eventName[1]) = 0">
            <xsl:text>XXXX EVENT-Angabe fehlt</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:choose>
               <xsl:when test="$first != ''">
                  <xsl:choose>
                     <xsl:when test="$event-entry/tei:eventName = ''">\textcolor{red}{EVENTNR INHALT
                        FEHLT}{ </xsl:when>
                     <xsl:otherwise>
                        <xsl:text>\eventindex{</xsl:text>
                        <xsl:if test="$ort != ''">
                           <xsl:value-of select="foo:index-sortiert(normalize-space($ort), 'bf')"/>
                           <xsl:text>!</xsl:text>
                        </xsl:if>
                        <xsl:value-of
                           select="foo:index-sortiert(normalize-space($event-entry/tei:eventName[1]), 'up')"/>
                        <xsl:if test="$typ != '' and not($ort = 'Wien' and $typ = 'Tageszeitung')">
                           <!--<xsl:text>, \emph{</xsl:text>
                           <xsl:value-of select="normalize-space($org-entry/Typ)"/>
                           <xsl:text>}</xsl:text>-->
                        </xsl:if>
                        <xsl:value-of select="$endung"/>
                     </xsl:otherwise>
                  </xsl:choose>
               </xsl:when>
            </xsl:choose>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <xsl:function name="foo:org-in-index">
      <xsl:param name="first" as="xs:string"/>
      <xsl:param name="endung" as="xs:string"/>
      <xsl:variable name="org-entry" select="key('org-lookup', ($first), $orgs)"/>
      <xsl:variable name="ort" select="$org-entry/tei:place[1]/tei:placeName[1]"/>
      <xsl:variable name="bezirk" select="$org-entry/*:Bezirk"/>
      <xsl:variable name="typ" select="$org-entry/tei:desc[1]/tei:gloss[1]"/>
      <xsl:choose>
         <xsl:when test="string-length($org-entry/tei:orgName[1]) = 0">
            <xsl:text>XXXX ORGangabe fehlt</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:choose>
               <xsl:when test="$first != ''">
                  <xsl:choose>
                     <xsl:when test="$org-entry/tei:orgName = ''">\textcolor{red}{ORGNR INHALT
                        FEHLT}{ </xsl:when>
                     <xsl:otherwise>
                        <xsl:text>\orgindex{</xsl:text>
                        <xsl:if test="$ort != ''">
                           <xsl:value-of select="foo:index-sortiert(normalize-space($ort), 'bf')"/>
                           <xsl:text>!</xsl:text>
                        </xsl:if>
                        <xsl:choose>
                           <xsl:when test="normalize-space($ort) = 'Wien'">
                              <xsl:choose>
                                 <xsl:when
                                    test="($bezirk = '' or empty($bezirk)) and (normalize-space($typ) = 'Tageszeitung')">
                                    <xsl:text>00 a@\emph{Tageszeitung}!</xsl:text>
                                 </xsl:when>
                                 <xsl:when
                                    test="$bezirk = '' or empty($bezirk) or starts-with($bezirk, 'Bezirksübergreifend')">
                                    <xsl:text>00 b@\textbf{Übergreifend}!</xsl:text>
                                 </xsl:when>
                                 <xsl:otherwise>
                                    <xsl:choose>
                                       <xsl:when test="substring-before($bezirk, '.') = 'I'">
                                          <xsl:text>01</xsl:text>
                                       </xsl:when>
                                       <xsl:when test="substring-before($bezirk, '.') = 'II'">
                                          <xsl:text>02</xsl:text>
                                       </xsl:when>
                                       <xsl:when test="substring-before($bezirk, '.') = 'III'">
                                          <xsl:text>03</xsl:text>
                                       </xsl:when>
                                       <xsl:when test="substring-before($bezirk, '.') = 'IV'">
                                          <xsl:text>04</xsl:text>
                                       </xsl:when>
                                       <xsl:when test="substring-before($bezirk, '.') = 'V'">
                                          <xsl:text>05</xsl:text>
                                       </xsl:when>
                                       <xsl:when test="substring-before($bezirk, '.') = 'VI'">
                                          <xsl:text>06</xsl:text>
                                       </xsl:when>
                                       <xsl:when test="substring-before($bezirk, '.') = 'VII'">
                                          <xsl:text>07</xsl:text>
                                       </xsl:when>
                                       <xsl:when test="substring-before($bezirk, '.') = 'VIII'">
                                          <xsl:text>08</xsl:text>
                                       </xsl:when>
                                       <xsl:when test="substring-before($bezirk, '.') = 'IX'">
                                          <xsl:text>09</xsl:text>
                                       </xsl:when>
                                       <xsl:when test="substring-before($bezirk, '.') = 'X'">
                                          <xsl:text>10</xsl:text>
                                       </xsl:when>
                                       <xsl:when test="substring-before($bezirk, '.') = 'XI'">
                                          <xsl:text>11</xsl:text>
                                       </xsl:when>
                                       <xsl:when test="substring-before($bezirk, '.') = 'XII'">
                                          <xsl:text>12</xsl:text>
                                       </xsl:when>
                                       <xsl:when test="substring-before($bezirk, '.') = 'XIII'">
                                          <xsl:text>13</xsl:text>
                                       </xsl:when>
                                       <xsl:when test="substring-before($bezirk, '.') = 'XIV'">
                                          <xsl:text>14</xsl:text>
                                       </xsl:when>
                                       <xsl:when test="substring-before($bezirk, '.') = 'XV'">
                                          <xsl:text>15</xsl:text>
                                       </xsl:when>
                                       <xsl:when test="substring-before($bezirk, '.') = 'XVI'">
                                          <xsl:text>16</xsl:text>
                                       </xsl:when>
                                       <xsl:when test="substring-before($bezirk, '.') = 'XVII'">
                                          <xsl:text>17</xsl:text>
                                       </xsl:when>
                                       <xsl:when test="substring-before($bezirk, '.') = 'XVIII'">
                                          <xsl:text>18</xsl:text>
                                       </xsl:when>
                                       <xsl:when test="substring-before($bezirk, '.') = 'XIX'">
                                          <xsl:text>19</xsl:text>
                                       </xsl:when>
                                       <xsl:when test="substring-before($bezirk, '.') = 'XX'">
                                          <xsl:text>20</xsl:text>
                                       </xsl:when>
                                       <xsl:when test="substring-before($bezirk, '.') = 'XXI'">
                                          <xsl:text>21</xsl:text>
                                       </xsl:when>
                                       <xsl:when test="substring-before($bezirk, '.') = 'XXII'">
                                          <xsl:text>22</xsl:text>
                                       </xsl:when>
                                       <xsl:when test="substring-before($bezirk, '.') = 'XXIII'">
                                          <xsl:text>23</xsl:text>
                                       </xsl:when>
                                    </xsl:choose>
                                    <xsl:value-of select="foo:index-sortiert($bezirk, 'bf')"/>
                                    <xsl:text>!</xsl:text>
                                 </xsl:otherwise>
                              </xsl:choose>
                           </xsl:when>
                        </xsl:choose>
                        <xsl:value-of
                           select="foo:index-sortiert(normalize-space($org-entry/tei:orgName[1]), 'up')"/>
                        <xsl:if test="$typ != '' and not($ort = 'Wien' and $typ = 'Tageszeitung')">
                           <!--<xsl:text>, \emph{</xsl:text>
                           <xsl:value-of select="normalize-space($org-entry/Typ)"/>
                           <xsl:text>}</xsl:text>-->
                        </xsl:if>
                        <xsl:value-of select="$endung"/>
                     </xsl:otherwise>
                  </xsl:choose>
               </xsl:when>
            </xsl:choose>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <xsl:function name="foo:absatz-position-vorne">
      <xsl:param name="rend" as="xs:string"/>
      <xsl:choose>
         <xsl:when test="$rend = 'center'">
            <xsl:text>\centering{}</xsl:text>
         </xsl:when>
         <xsl:when test="$rend = 'right'">
            <xsl:text>\raggedleft{}</xsl:text>
         </xsl:when>
      </xsl:choose>
   </xsl:function>
   <xsl:function name="foo:absatz-position-hinten">
      <xsl:param name="rend" as="xs:string"/>
      <xsl:choose>
         <xsl:when test="$rend = 'center'">
            <xsl:text/>
         </xsl:when>
         <xsl:when test="$rend = 'right'">
            <xsl:text/>
         </xsl:when>
      </xsl:choose>
   </xsl:function>
   <!-- Dient dazu, in der Kopfzeile »März 1890« erscheinen zu lassen -->
   <xsl:function name="foo:Monatsname">
      <xsl:param name="monat" as="xs:string"/>
      <xsl:choose>
         <xsl:when test="$monat = '01'">
            <xsl:text>Januar </xsl:text>
         </xsl:when>
         <xsl:when test="$monat = '02'">
            <xsl:text>Februar </xsl:text>
         </xsl:when>
         <xsl:when test="$monat = '03'">
            <xsl:text>März </xsl:text>
         </xsl:when>
         <xsl:when test="$monat = '04'">
            <xsl:text>April </xsl:text>
         </xsl:when>
         <xsl:when test="$monat = '05'">
            <xsl:text>Mai </xsl:text>
         </xsl:when>
         <xsl:when test="$monat = '06'">
            <xsl:text>Juni </xsl:text>
         </xsl:when>
         <xsl:when test="$monat = '07'">
            <xsl:text>Juli </xsl:text>
         </xsl:when>
         <xsl:when test="$monat = '08'">
            <xsl:text>August </xsl:text>
         </xsl:when>
         <xsl:when test="$monat = '09'">
            <xsl:text>September </xsl:text>
         </xsl:when>
         <xsl:when test="$monat = '10'">
            <xsl:text>Oktober </xsl:text>
         </xsl:when>
         <xsl:when test="$monat = '11'">
            <xsl:text>November </xsl:text>
         </xsl:when>
         <xsl:when test="$monat = '12'">
            <xsl:text>Dezember </xsl:text>
         </xsl:when>
      </xsl:choose>
   </xsl:function>
   <!-- Dient dazu, in der Kopfzeile »März 1890« erscheinen zu lassen -->
   <xsl:function name="foo:monatUndJahrInKopfzeile">
      <xsl:param name="datum" as="xs:string"/>
      <xsl:variable name="monat" as="xs:string?" select="substring($datum, 5, 2)"/>
      <xsl:text>\lohead{\textsc{</xsl:text>
      <xsl:choose>
         <xsl:when test="$monat = '01'">
            <xsl:text>januar </xsl:text>
         </xsl:when>
         <xsl:when test="$monat = '02'">
            <xsl:text>februar </xsl:text>
         </xsl:when>
         <xsl:when test="$monat = '03'">
            <xsl:text>märz </xsl:text>
         </xsl:when>
         <xsl:when test="$monat = '04'">
            <xsl:text>april </xsl:text>
         </xsl:when>
         <xsl:when test="$monat = '05'">
            <xsl:text>mai </xsl:text>
         </xsl:when>
         <xsl:when test="$monat = '06'">
            <xsl:text>juni </xsl:text>
         </xsl:when>
         <xsl:when test="$monat = '07'">
            <xsl:text>juli </xsl:text>
         </xsl:when>
         <xsl:when test="$monat = '08'">
            <xsl:text>august </xsl:text>
         </xsl:when>
         <xsl:when test="$monat = '09'">
            <xsl:text>september </xsl:text>
         </xsl:when>
         <xsl:when test="$monat = '10'">
            <xsl:text>oktober </xsl:text>
         </xsl:when>
         <xsl:when test="$monat = '11'">
            <xsl:text>november </xsl:text>
         </xsl:when>
         <xsl:when test="$monat = '12'">
            <xsl:text>dezember </xsl:text>
         </xsl:when>
      </xsl:choose>
      <xsl:value-of select="substring($datum, 1, 4)"/>
      <xsl:text>}}</xsl:text>
   </xsl:function>
   <xsl:function name="foo:date-repeat">
      <xsl:param name="date-string" as="xs:string"/>
      <xsl:param name="amount" as="xs:integer"/>
      <xsl:param name="counter" as="xs:integer"/>
      <xsl:variable name="roman" select="'IVX'"/>
      <xsl:variable name="romanzwo" select="'IVX.'"/>
      <xsl:variable name="monatjahr" select="normalize-space(substring-after($date-string, '.'))"/>
      <xsl:variable name="jahr" select="normalize-space(substring-after($monatjahr, '.'))"/>
      <xsl:choose>
         <xsl:when
            test="number(substring-before($date-string, '.')) = number(substring-before($date-string, '.')) and number(substring-before($monatjahr, '.')) = number(substring-before($monatjahr, '.')) and number($jahr) = number($jahr)">
            <xsl:value-of select="substring-before($date-string, '.')"/>
            <xsl:text>.&#8239;</xsl:text>
            <xsl:value-of select="substring-before($monatjahr, '.')"/>
            <xsl:text>.&#8239;</xsl:text>
            <xsl:value-of select="$jahr"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:choose>
               <!-- Fall 1: Leerzeichen und davor Punkt und Zahl -->
               <xsl:when
                  test="substring($date-string, $counter, 1) = ' ' and substring($date-string, $counter - 1, 1) = '.' and number(substring($date-string, $counter - 2, 1)) = number(substring($date-string, $counter - 2, 1))">
                  <xsl:choose>
                     <xsl:when
                        test="number(substring($date-string, $counter + 1, 1)) = number(substring($date-string, $counter + 1, 1))">
                        <xsl:text>&#8239;</xsl:text>
                     </xsl:when>
                     <xsl:when
                        test="substring($date-string, $counter + 1, 1) = '[' and number(substring($date-string, $counter + 2, 1)) = number(substring($date-string, $counter + 2, 1))">
                        <xsl:text>&#8239;</xsl:text>
                     </xsl:when>
                     <xsl:when
                        test="string-length(translate(substring($date-string, $counter + 1, 1), $roman, '')) = 0 and string-length(translate(substring($date-string, $counter + 2, 1), $romanzwo, '')) = 0">
                        <xsl:text>&#8239;</xsl:text>
                     </xsl:when>
                     <xsl:otherwise>
                        <xsl:value-of select="substring($date-string, $counter, 1)"/>
                     </xsl:otherwise>
                  </xsl:choose>
               </xsl:when>
               <!-- Fall 2: Leerzeichen und davor eckige Klammer und Zahl -->
               <xsl:when
                  test="substring($date-string, $counter, 1) = ' ' and (substring($date-string, $counter - 2, 2) = '.]' and number(substring($date-string, $counter - 3, 1)) = number(substring($date-string, $counter - 3, 1)))">
                  <xsl:choose>
                     <xsl:when
                        test="number(substring($date-string, $counter + 1, 1)) = number(substring($date-string, $counter + 1, 1))">
                        <xsl:text>&#8239;</xsl:text>
                     </xsl:when>
                     <xsl:when
                        test="substring($date-string, $counter + 1, 1) = '[' and number(substring($date-string, $counter + 2, 1)) = number(substring($date-string, $counter + 2, 1))">
                        <xsl:text>&#8239;</xsl:text>
                     </xsl:when>
                     <xsl:when
                        test="string-length(translate(substring($date-string, $counter + 1, 1), $roman, '')) = 0 and string-length(translate(substring($date-string, $counter + 2, 1), $romanzwo, '')) = 0">
                        <xsl:text>&#8239;</xsl:text>
                     </xsl:when>
                     <xsl:otherwise>
                        <xsl:value-of select="substring($date-string, $counter, 1)"/>
                     </xsl:otherwise>
                  </xsl:choose>
               </xsl:when>
               <!-- Fall 3: Leerzeichen und davor römische Zahl -->
               <xsl:when
                  test="substring($date-string, $counter, 1) = ' ' and substring($date-string, $counter - 1, 1) = '.' and string-length(translate(substring($date-string, $counter - 2, 1), $roman, '')) = 0">
                  <xsl:choose>
                     <xsl:when
                        test="number(substring($date-string, $counter + 1, 1)) = number(substring($date-string, $counter + 1, 1))">
                        <xsl:text>&#8239;</xsl:text>
                     </xsl:when>
                     <xsl:when
                        test="substring($date-string, $counter + 1, 1) = '[' and number(substring($date-string, $counter + 2, 1)) = number(substring($date-string, $counter + 2, 1))">
                        <xsl:text>&#8239;</xsl:text>
                     </xsl:when>
                     <xsl:otherwise>
                        <xsl:value-of select="substring($date-string, $counter, 1)"/>
                     </xsl:otherwise>
                  </xsl:choose>
               </xsl:when>
               <xsl:when test="substring($date-string, $counter, 1) = '['">
                  <xsl:text>{[}</xsl:text>
               </xsl:when>
               <xsl:when test="substring($date-string, $counter, 1) = ']'">
                  <xsl:text>{]}</xsl:text>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="substring($date-string, $counter, 1)"/>
               </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="$counter &lt;= $amount">
               <xsl:value-of select="foo:date-repeat($date-string, $amount, $counter + 1)"/>
            </xsl:if>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <xsl:function name="foo:section-titel-token">
      <!-- Das gibt den Titel für das Inhaltsverzeichnis aus. Immer nach 55 Zeichen wird umgebrochen -->
      <xsl:param name="titel" as="xs:string"/>
      <xsl:param name="position" as="xs:integer"/>
      <xsl:param name="bereitsausgegeben" as="xs:integer"/>
      <xsl:choose>
         <xsl:when
            test="string-length(substring(substring-before($titel, tokenize($titel, ' ')[$position + 1]), $bereitsausgegeben)) &lt; 55">
            <xsl:value-of
               select="replace(replace(tokenize($titel, ' ')[$position], '\[', '{[}'), '\]', '{]}')"/>
            <xsl:choose>
               <xsl:when
                  test="not(tokenize($titel, ' ')[$position] = tokenize($titel, ' ')[last()])">
                  <xsl:text> </xsl:text>
                  <xsl:value-of
                     select="foo:section-titel-token($titel, $position + 1, $bereitsausgegeben)"/>
               </xsl:when>
            </xsl:choose>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>\\{}</xsl:text>
            <xsl:value-of
               select="replace(replace(tokenize($titel, ' ')[$position], '\[', '{[}'), '\]', '{]}')"/>
            <xsl:choose>
               <xsl:when
                  test="not(tokenize($titel, ' ')[$position] = tokenize($titel, ' ')[last()])">
                  <xsl:text> </xsl:text>
                  <xsl:value-of
                     select="foo:section-titel-token($titel, $position + 1, string-length(substring-before($titel, tokenize($titel, ' ')[$position + 1])))"
                  />
               </xsl:when>
            </xsl:choose>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <xsl:function name="foo:sectionInToc">
      <xsl:param name="titel" as="xs:string"/>
      <xsl:variable name="datum" as="xs:string"
         select="tokenize(normalize-space($titel), ', ')[last()]"/>
      <xsl:variable name="titelminusdatum" as="xs:string"
         select="normalize-space(substring-before(normalize-space($titel), $datum))"/>
      <xsl:value-of select="replace(replace($titelminusdatum, '\[', '{[}'), '\]', '{]}')"/>
      <xsl:text> </xsl:text>
      <xsl:value-of select="foo:date-translate($datum)"/>
   </xsl:function>
   <!-- HAUPT -->
   <xsl:template match="tei:root">
      <root>
         <xsl:apply-templates/>
      </root>
   </xsl:template>
   <xsl:template match="tei:TEI[starts-with(@xml:id, 'E_')]">
      <root>
         <xsl:text>\addchap{</xsl:text>
         <xsl:value-of
            select="normalize-space(teiHeader[1]/tei:fileDesc[1]/tei:titleStmt[1]/tei:title[@level = 'a'])"/>
         <xsl:text>}</xsl:text>
         <xsl:text>\lohead{\textsc{</xsl:text>
         <xsl:value-of
            select="descendant::tei:titleStmt/tei:title[@level = 'a']/fn:normalize-space(.)"/>
         <xsl:text>}}</xsl:text>
         <xsl:text>\mylabel{</xsl:text>
         <xsl:value-of select="concat(foo:umlaute-entfernen(@xml:id), 'v')"/>
         <xsl:text>}</xsl:text>
         <xsl:apply-templates select="tei:text"/>
         <xsl:text>\mylabel{</xsl:text>
         <xsl:value-of select="concat(foo:umlaute-entfernen(@xml:id), 'h')"/>
         <xsl:text>}</xsl:text>
         <xsl:text>\vspace{0.4em}</xsl:text>
      </root>
   </xsl:template>
   <xsl:template match="tei:TEI[not(starts-with(@xml:id, 'E_'))]">
      <root>
         <xsl:variable name="jahr-davor" as="xs:string"
            select="substring(preceding-sibling::tei:TEI[1]/@when, 1, 4)"/>
         <xsl:variable name="correspAction-date">
            <!-- Datum für die Sortierung -->
            <xsl:choose>
               <xsl:when test="descendant::tei:correspDesc/tei:correspAction[@type = 'sent']">
                  <xsl:variable name="correspDate"
                     select="descendant::tei:correspDesc/tei:correspAction[@type = 'sent']/tei:date"/>
                  <xsl:choose>
                     <xsl:when test="@when">
                        <xsl:value-of select="@when"/>
                     </xsl:when>
                     <xsl:when test="@from">
                        <xsl:value-of select="@from"/>
                     </xsl:when>
                     <xsl:when test="@notBefore">
                        <xsl:value-of select="@notBefore"/>
                     </xsl:when>
                     <xsl:when test="@to">
                        <xsl:value-of select="@to"/>
                     </xsl:when>
                     <xsl:when test="@notAfter">
                        <xsl:value-of select="@notAfter"/>
                     </xsl:when>
                     <xsl:otherwise>
                        <xsl:text>XXXX Datumsproblem in correspDesc</xsl:text>
                     </xsl:otherwise>
                  </xsl:choose>
               </xsl:when>
               <xsl:when test="descendant::tei:sourceDesc[1]/tei:listWit/tei:witness">
                  <xsl:choose>
                     <xsl:when
                        test="descendant::tei:sourceDesc[1]/tei:listWit/tei:witness//tei:date/@when">
                        <xsl:value-of
                           select="descendant::tei:sourceDesc[1]/tei:listWit/tei:witness//tei:date/@when"
                        />
                     </xsl:when>
                     <xsl:otherwise>
                        <xsl:text>XXXX Datumsproblem beim Archivzeugen</xsl:text>
                     </xsl:otherwise>
                  </xsl:choose>
               </xsl:when>
               <xsl:when test="descendant::tei:sourceDesc[1]/tei:listBibl[1]//tei:origDate[1]/@when">
                  <xsl:value-of
                     select="descendant::tei:sourceDesc[1]/tei:listBibl[1]//tei:origDate[1]/@when"/>
               </xsl:when>
               <xsl:when
                  test="descendant::tei:sourceDesc[1]/tei:listBibl[1]/tei:biblStruct[1]/tei:date/@when">
                  <xsl:value-of
                     select="descendant::tei:sourceDesc[1]/tei:listBibl[1]/tei:biblStruct[1]/tei:date/@when"
                  />
               </xsl:when>
               <xsl:otherwise>
                  <xsl:text>XXXX Datumsproblem </xsl:text>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:variable>
         <xsl:variable name="dokument-id" select="@xml:id"/>
         <xsl:if test="substring(@when, 1, 4) != $jahr-davor">
            <xsl:text>\leavevmode\addchap*{</xsl:text>
            <xsl:value-of select="substring(@when, 1, 4)"/>
            <xsl:text>}
      </xsl:text>
         </xsl:if>
         <xsl:choose>
            <xsl:when test="starts-with($dokument-id, 'E_')">
               <!-- Herausgeber*innentext -->
               <xsl:text>\leavevmode\addchap{</xsl:text>
               <xsl:value-of
                  select="normalize-space(teiHeader[1]/tei:fileDesc[1]/tei:titleStmt[1]/tei:title[@level = 'a'])"/>
               <xsl:text>}</xsl:text>
            </xsl:when>
            <xsl:otherwise>
               <xsl:text>\input{../tex-inputs/latex-korrekturansicht-vorspann}
</xsl:text>
               <xsl:apply-templates select="tei:text/back" mode="tex"/>
               <xsl:text>&#10;\section[</xsl:text>
               <xsl:value-of
                  select="foo:sectionInToc(descendant::tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@level = 'a'])"/>
               <xsl:text>]{</xsl:text>
               <xsl:if test="$dokument-id != ''">
                  <xsl:value-of select="$dokument-id"/>
                  <xsl:text> </xsl:text>
               </xsl:if>
               <xsl:value-of
                  select="substring-before(tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@level = 'a'], tokenize(tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@level = 'a'], ',')[last()])"/>
               <xsl:text> </xsl:text>
               <xsl:value-of
                  select="foo:date-translate(tokenize(tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@level = 'a'], ',')[last()])"/>
               <xsl:text>}</xsl:text>
            </xsl:otherwise>
         </xsl:choose>
         <xsl:text>&#10;\nopagebreak\mylabel{</xsl:text>
         <xsl:value-of select="concat($dokument-id, 'v')"/>
         <xsl:text>}</xsl:text>
         <xsl:if test="not(starts-with(@xml:id, 'E'))">
            <xsl:text>&#10;\rehead{</xsl:text>
            <xsl:value-of
               select="concat(key('person-lookup', (@bw), $persons)/tei:persName/tei:forename, ' ', key('person-lookup', (@bw), $persons)/tei:persName/tei:surname)"/>
            <xsl:text>}</xsl:text>
         </xsl:if>
         <xsl:apply-templates select="tei:image"/>
         <xsl:apply-templates select="tei:text"/>
         <xsl:text>\mylabel{</xsl:text>
         <xsl:value-of select="concat($dokument-id, 'h')"/>
         <xsl:text>}</xsl:text>
         <!-- <xsl:text>\leavevmode{}</xsl:text>-->
         <xsl:choose>
            <xsl:when
               test="descendant::tei:revisionDesc[@status = 'proposed'] and count(descendant::tei:revisionDesc/tei:change[contains(text(), 'Index check')]) = 0">
               <xsl:text>&#10;\begin{anhang}</xsl:text>
               <xsl:apply-templates select="tei:teiHeader"/>
               <xsl:text>&#10;\end{anhang}</xsl:text>
            </xsl:when>
            <xsl:otherwise>  <xsl:apply-templates select="tei:teiHeader"/>
               <!--            <xsl:text>\doendnotes{B}</xsl:text>
-->
            </xsl:otherwise>
         </xsl:choose>
      </root>
      <xsl:text>\input{../tex-inputs/latex-korrekturansicht-abspann}
      </xsl:text>
   </xsl:template>
   <xsl:template match="tei:teiHeader">
      <xsl:apply-templates/>
   </xsl:template>
   <xsl:template match="tei:origDate"/>
   <xsl:template match="tei:text">
      <xsl:apply-templates/>
   </xsl:template>
   <xsl:template match="tei:title"/>
   <xsl:template match="tei:frame">
      <xsl:text>\begin{mdbar}</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>\end{mdbar}</xsl:text>
   </xsl:template>
   <xsl:template match="tei:funder"/>
   <xsl:template match="tei:editionStmt"/>
   <xsl:template match="tei:seriesStmt"/>
   <xsl:template match="tei:publicationStmt"/>
   <xsl:function name="foo:witnesse-als-item">
      <xsl:param name="witness-count" as="xs:integer"/>
      <xsl:param name="witnesse" as="xs:integer"/>
      <xsl:param name="listWitnode" as="node()"/>
      <xsl:text>\item </xsl:text>
      <xsl:apply-templates select="$listWitnode/tei:witness[$witness-count - $witnesse + 1]"/>
      <xsl:if test="$witnesse &gt; 1">
         <xsl:apply-templates
            select="foo:witnesse-als-item($witness-count, $witnesse - 1, $listWitnode)"/>
      </xsl:if>
   </xsl:function>
   <xsl:template match="tei:sourceDesc"/>
   <xsl:template match="tei:profileDesc"/>
   <xsl:function name="foo:briefsender-rekursiv">
      <xsl:param name="empfaenger" as="node()"/>
      <xsl:param name="empfaengernummer" as="xs:integer"/>
      <xsl:param name="sender-key" as="xs:string"/>
      <xsl:param name="date-sort" as="xs:integer"/>
      <xsl:param name="date-n" as="xs:integer"/>
      <xsl:param name="datum" as="xs:string"/>
      <xsl:param name="vorne" as="xs:boolean"/>
      <xsl:value-of
         select="foo:briefsenderindex($sender-key, $empfaenger/tei:persName[$empfaengernummer]/@ref, $date-sort, $date-n, $datum, $vorne)"/>
      <xsl:if test="$empfaengernummer &gt; 1">
         <xsl:value-of
            select="foo:briefsender-rekursiv($empfaenger, $empfaengernummer - 1, $sender-key, $date-sort, $date-n, $datum, $vorne)"
         />
      </xsl:if>
   </xsl:function>
   <xsl:function name="foo:sender-empfaenger-in-personenindex-rekursiv">
      <xsl:param name="sender-empfaenger" as="node()"/>
      <xsl:param name="sender-nichtempfaenger" as="xs:boolean"/>
      <xsl:param name="nummer" as="xs:integer"/>
      <!--    <xsl:value-of select="foo:sender-empfaenger-in-personenindex($sender-empfaenger/tei:persName[$nummer]/@ref, $sender-nichtempfaenger)"/>
      <xsl:if test="$nummer &gt; 1">
         <xsl:value-of select="foo:sender-empfaenger-in-personenindex-rekursiv($sender-empfaenger, $sender-nichtempfaenger, $nummer - 1)"/>
      </xsl:if>-->
   </xsl:function>
   <xsl:function name="foo:sender-empfaenger-in-personenindex">
      <xsl:param name="sender-key" as="xs:string"/>
      <xsl:param name="sender-nichtempfaenger" as="xs:boolean"/>
      <xsl:choose>
         <!-- Briefsender fett in den Personenindex -->
         <xsl:when test="not($sender-key = '#pmb2121')">
            <!-- Schnitzler und Bahr nicht -->
            <xsl:text>\pwindex{</xsl:text>
            <xsl:value-of select="foo:person-fuer-index($sender-key)"/>
            <xsl:choose>
               <xsl:when test="$sender-nichtempfaenger = true()">
                  <xsl:text>|pws</xsl:text>
               </xsl:when>
               <xsl:when test="$sender-nichtempfaenger = false()">
                  <xsl:text>|pwe</xsl:text>
               </xsl:when>
            </xsl:choose>
            <xsl:text>}</xsl:text>
         </xsl:when>
      </xsl:choose>
   </xsl:function>
   <xsl:function name="foo:briefsenderindex">
      <xsl:param name="sender-key" as="xs:string"/>
      <xsl:param name="empfaenger-key" as="xs:string"/>
      <xsl:param name="date-sort" as="xs:integer"/>
      <xsl:param name="date-n" as="xs:integer"/>
      <xsl:param name="datum" as="xs:string"/>
      <xsl:param name="vorne" as="xs:boolean"/>
      <xsl:text>\briefsenderindex{</xsl:text>
      <xsl:value-of
         select="foo:index-sortiert(concat(normalize-space(key('person-lookup', ($sender-key), $persons)/tei:persName/tei:surname), ', ', normalize-space(key('person-lookup', ($sender-key), $persons)/tei:persName/tei:forename)), 'sc')"/>
      <xsl:text>!</xsl:text>
      <xsl:value-of
         select="foo:umlaute-entfernen(concat(normalize-space(key('person-lookup', ($empfaenger-key), $persons)/tei:persName/tei:surname), ', ', normalize-space(key('person-lookup', ($empfaenger-key), $persons)/tei:persName/tei:forename)))"/>
      <xsl:text>@\emph{an </xsl:text>
      <xsl:value-of
         select="concat(normalize-space(key('person-lookup', ($empfaenger-key), $persons)/tei:persName/tei:forename), ' ', normalize-space(key('person-lookup', ($empfaenger-key), $persons)/tei:persName/tei:surname))"/>
      <xsl:text>}!</xsl:text>
      <xsl:value-of select="$date-sort"/>
      <xsl:value-of select="$date-n"/>
      <xsl:text>@{</xsl:text>
      <xsl:value-of select="foo:date-translate($datum)"/>
      <xsl:text>}</xsl:text>
      <xsl:value-of select="foo:vorne-hinten($vorne)"/>
      <xsl:text>bs}</xsl:text>
   </xsl:function>
   <xsl:function name="foo:briefempfaenger-rekursiv">
      <xsl:param name="sender" as="node()"/>
      <xsl:param name="sendernummer" as="xs:integer"/>
      <xsl:param name="empfaenger-key" as="xs:string"/>
      <xsl:param name="date-sort" as="xs:date?"/>
      <xsl:param name="date-n" as="xs:integer"/>
      <xsl:param name="datum" as="xs:string"/>
      <xsl:param name="vorne" as="xs:boolean"/>
      <xsl:value-of select="
            foo:briefempfaengerindex($empfaenger-key,
            $sender/tei:persName[$sendernummer]/@ref,
            $date-sort,
            $date-n,
            $datum,
            $vorne)"/>
      <xsl:if test="$sendernummer &gt; 1">
         <xsl:value-of
            select="foo:briefempfaenger-rekursiv($sender, $sendernummer - 1, $empfaenger-key, $date-sort, $date-n, $datum, $vorne)"
         />
      </xsl:if>
   </xsl:function>
   <xsl:function name="foo:briefempfaengerindex">
      <xsl:param name="empfaenger-key" as="xs:string"/>
      <xsl:param name="sender-key" as="xs:string"/>
      <xsl:param name="date-sort" as="xs:date?"/>
      <xsl:param name="date-n" as="xs:integer"/>
      <xsl:param name="datum" as="xs:string"/>
      <xsl:param name="vorne" as="xs:boolean"/>
      <xsl:text>\briefempfaengerindex{</xsl:text>
      <xsl:value-of
         select="foo:index-sortiert(concat(normalize-space(key('person-lookup', ($empfaenger-key), $persons)/tei:persName/tei:surname), ', ', normalize-space(key('person-lookup', ($empfaenger-key), $persons)/tei:persName/tei:forename)), 'sc')"/>
      <xsl:text>!zzz</xsl:text>
      <xsl:value-of
         select="foo:umlaute-entfernen(concat(normalize-space(key('person-lookup', ($sender-key), $persons)/tei:persName/tei:surname), ', ', normalize-space(key('person-lookup', ($sender-key), $persons)/tei:persName/tei:forename)))"/>
      <xsl:text>@\emph{von </xsl:text>
      <xsl:choose>
         <!-- Sonderregel für Hofmannsthal sen. -->
         <xsl:when
            test="ends-with(key('person-lookup', $sender-key, $persons)/tei:persName/tei:forename, ' (sen.)')">
            <xsl:value-of
               select="concat(substring-before(normalize-space(key('person-lookup', ($sender-key), $persons)/tei:persName/tei:forename), ' (sen.)'), ' ', normalize-space(key('person-lookup', ($sender-key), $persons)/tei:persName/tei:surname))"/>
            <xsl:text> (sen.)</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of
               select="concat(normalize-space(key('person-lookup', ($sender-key), $persons)/tei:persName/tei:forename), ' ', normalize-space(key('person-lookup', ($sender-key), $persons)/tei:persName/tei:surname))"
            />
         </xsl:otherwise>
      </xsl:choose>
      <xsl:text>}</xsl:text>
      <!--Das hier würde das Datum der Korrespondenzstücke der Briefempfänger einfügen. Momentan nur der Name-->
      <xsl:text>!</xsl:text>
      <xsl:value-of select="$date-sort"/>
      <xsl:value-of select="$date-n"/>
      <xsl:text>@{</xsl:text>
      <xsl:value-of select="foo:date-translate($datum)"/>
      <xsl:text>}</xsl:text>
      <xsl:value-of select="foo:vorne-hinten($vorne)"/>
      <xsl:text>be}</xsl:text>
   </xsl:function>
   <xsl:template match="tei:msIdentifier/tei:country"/>
   <xsl:template match="tei:incident">
      <xsl:apply-templates select="tei:desc"/>
   </xsl:template>
   <xsl:template match="tei:additions">
      <xsl:apply-templates select="tei:incident[@type = 'attachment']"/>
      <xsl:apply-templates select="tei:incident[@type = 'postal']"/>
      <xsl:apply-templates select="tei:incident[@type = 'receiver']"/>
      <xsl:apply-templates select="tei:incident[@type = 'archival']"/>
      <xsl:apply-templates select="tei:incident[@type = 'additional-information']"/>
      <xsl:apply-templates select="tei:incident[@type = 'editorial']"/>
   </xsl:template>
   <xsl:template match="tei:incident[@type = 'attachment']/tei:desc">
      <xsl:variable name="poschitzion"
         select="count(parent::tei:incident/preceding-sibling::tei:incident[@type = 'attachment'])"/>
      <xsl:choose>
         <xsl:when test="$poschitzion &gt; 0">
            <xsl:text> </xsl:text>
            <xsl:value-of select="$poschitzion + 1"/>
            <xsl:text>)&#160;</xsl:text>
            <xsl:apply-templates/>
         </xsl:when>
         <xsl:when
            test="$poschitzion = 0 and not(parent::tei:incident/following-sibling::tei:incident[@type = 'attachment'])">
            <xsl:text>&#10;\newline{}Beilage: </xsl:text>
            <xsl:apply-templates/>
            <xsl:text> </xsl:text>
         </xsl:when>
         <xsl:when
            test="$poschitzion = 0 and parent::tei:incident/following-sibling::tei:incident[@type = 'attachment']">
            <xsl:text>&#10;\newline{}Beilagen: </xsl:text>
            <xsl:value-of select="$poschitzion + 1"/>
            <xsl:text>)&#160;</xsl:text>
            <xsl:apply-templates/>
            <xsl:text> </xsl:text>
         </xsl:when>
      </xsl:choose>
   </xsl:template>
   <xsl:template match="tei:desc[parent::tei:incident[@type = 'postal']]">
      <xsl:variable name="poschitzion"
         select="count(parent::tei:incident/preceding-sibling::tei:incident[@type = 'postal'])"/>
      <xsl:choose>
         <xsl:when test="$poschitzion &gt; 0">
            <xsl:text> </xsl:text>
            <xsl:value-of select="$poschitzion + 1"/>
            <xsl:text>)&#160;</xsl:text>
            <xsl:value-of select="foo:incident-rend(parent::tei:incident/@rend)"/>
            <xsl:apply-templates/>
         </xsl:when>
         <xsl:when
            test="$poschitzion = 0 and not(parent::tei:incident/following-sibling::tei:incident[@type = 'postal'])">
            <xsl:text>&#10;\newline{}Versand: </xsl:text>
            <xsl:value-of select="foo:incident-rend(parent::tei:incident/@rend)"/>
            <xsl:apply-templates/>
            <xsl:text> </xsl:text>
         </xsl:when>
         <xsl:when
            test="$poschitzion = 0 and parent::tei:incident/following-sibling::tei:incident[@type = 'postal']">
            <xsl:text>&#10;\newline{}Versand: </xsl:text>
            <xsl:value-of select="$poschitzion + 1"/>
            <xsl:text>)&#160;</xsl:text>
            <xsl:value-of select="foo:incident-rend(parent::tei:incident/@rend)"/>
            <xsl:apply-templates/>
            <xsl:text> </xsl:text>
         </xsl:when>
      </xsl:choose>
   </xsl:template>
   <xsl:template match="tei:incident[@type = 'receiver']/tei:desc">
      <xsl:variable name="receiver"
         select="substring-before(ancestor::tei:teiHeader//tei:correspDesc/tei:correspAction[@type = 'received']/tei:persName[1], ',')"/>
      <xsl:variable name="poschitzion"
         select="count(parent::tei:incident/preceding-sibling::tei:incident[@type = 'receiver'])"/>
      <xsl:choose>
         <xsl:when test="$poschitzion &gt; 0">
            <xsl:text> </xsl:text>
            <xsl:value-of select="$poschitzion + 1"/>
            <xsl:text>)&#160;</xsl:text>
            <xsl:value-of select="foo:incident-rend(parent::tei:incident/@rend)"/>
            <xsl:apply-templates/>
         </xsl:when>
         <xsl:when
            test="$poschitzion = 0 and parent::tei:incident/following-sibling::tei:incident[@type = 'receiver']">
            <xsl:text>&#10;\newline{}</xsl:text>
            <xsl:value-of select="$receiver"/>
            <xsl:text>: </xsl:text>
            <xsl:value-of select="$poschitzion + 1"/>
            <xsl:text>)&#160;</xsl:text>
            <xsl:value-of select="foo:incident-rend(parent::tei:incident/@rend)"/>
            <xsl:apply-templates/>
            <xsl:text> </xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>&#10;\newline{}</xsl:text>
            <xsl:value-of select="$receiver"/>
            <xsl:text>: </xsl:text>
            <xsl:value-of select="foo:incident-rend(parent::tei:incident/@rend)"/>
            <xsl:apply-templates/>
            <xsl:text> </xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:template match="tei:desc[parent::tei:incident[@type = 'archival']]">
      <xsl:variable name="poschitzion"
         select="count(parent::tei:incident/preceding-sibling::tei:incident[@type = 'archival'])"/>
      <xsl:choose>
         <xsl:when test="$poschitzion &gt; 0">
            <xsl:text> </xsl:text>
            <xsl:value-of select="$poschitzion + 1"/>
            <xsl:text>)&#160;</xsl:text>
            <xsl:value-of select="foo:incident-rend(parent::tei:incident/@rend)"/>
            <xsl:apply-templates/>
         </xsl:when>
         <xsl:when
            test="$poschitzion = 0 and not(parent::tei:incident/following-sibling::tei:incident[@type = 'archival'])">
            <xsl:text>&#10;\newline{}Ordnung: </xsl:text>
            <xsl:value-of select="foo:incident-rend(parent::tei:incident/@rend)"/>
            <xsl:apply-templates/>
            <xsl:text> </xsl:text>
         </xsl:when>
         <xsl:when
            test="$poschitzion = 0 and parent::tei:incident/following-sibling::tei:incident[@type = 'archival']">
            <xsl:text>&#10;\newline{}Ordnung: </xsl:text>
            <xsl:value-of select="$poschitzion + 1"/>
            <xsl:text>)&#160;</xsl:text>
            <xsl:value-of select="foo:incident-rend(parent::tei:incident/@rend)"/>
            <xsl:apply-templates/>
            <xsl:text> </xsl:text>
         </xsl:when>
      </xsl:choose>
   </xsl:template>
   <xsl:template match="tei:desc[parent::tei:incident[@type = 'additional-information']]">
      <xsl:variable name="poschitzion"
         select="count(parent::tei:incident/preceding-sibling::tei:incident[@type = 'additional-information'])"/>
      <xsl:choose>
         <xsl:when test="$poschitzion &gt; 0">
            <xsl:text> </xsl:text>
            <xsl:value-of select="$poschitzion + 1"/>
            <xsl:text>)&#160;</xsl:text>
            <xsl:value-of select="foo:incident-rend(parent::tei:incident/@rend)"/>
            <xsl:apply-templates/>
         </xsl:when>
         <xsl:when
            test="$poschitzion = 0 and not(parent::tei:incident/following-sibling::tei:incident[@type = 'additional-information'])">
            <xsl:text>&#10;\newline{}Zusatz: </xsl:text>
            <xsl:value-of select="foo:incident-rend(parent::tei:incident/@rend)"/>
            <xsl:apply-templates/>
            <xsl:text> </xsl:text>
         </xsl:when>
         <xsl:when
            test="$poschitzion = 0 and parent::tei:incident/following-sibling::tei:incident[@type = 'additional-information']">
            <xsl:text>&#10;\newline{}Zusatz: </xsl:text>
            <xsl:value-of select="$poschitzion + 1"/>
            <xsl:text>)&#160;</xsl:text>
            <xsl:value-of select="foo:incident-rend(parent::tei:incident/@rend)"/>
            <xsl:apply-templates/>
            <xsl:text> </xsl:text>
         </xsl:when>
      </xsl:choose>
   </xsl:template>
   <xsl:template match="tei:desc[parent::tei:incident[@type = 'editorial']]">
      <xsl:variable name="poschitzion"
         select="count(parent::tei:incident/preceding-sibling::tei:incident[@type = 'editorial'])"/>
      <xsl:choose>
         <xsl:when test="$poschitzion &gt; 0">
            <xsl:text> </xsl:text>
            <xsl:value-of select="$poschitzion + 1"/>
            <xsl:text>)&#160;</xsl:text>
            <xsl:value-of select="foo:incident-rend(parent::tei:incident/@rend)"/>
            <xsl:apply-templates/>
         </xsl:when>
         <xsl:when
            test="$poschitzion = 0 and not(parent::tei:incident/following-sibling::tei:incident[@type = 'editorial'])">
            <xsl:text>&#10;\newline{}Editorischer Hinweis: </xsl:text>
            <xsl:value-of select="foo:incident-rend(parent::tei:incident/@rend)"/>
            <xsl:apply-templates/>
            <xsl:text> </xsl:text>
         </xsl:when>
         <xsl:when
            test="$poschitzion = 0 and parent::tei:incident/following-sibling::tei:incident[@type = 'editorial']">
            <xsl:text>&#10;\newline{}Editorischer Hinweise: </xsl:text>
            <xsl:value-of select="$poschitzion + 1"/>
            <xsl:text>)&#160;</xsl:text>
            <xsl:value-of select="foo:incident-rend(parent::tei:incident/@rend)"/>
            <xsl:apply-templates/>
            <xsl:text> </xsl:text>
         </xsl:when>
      </xsl:choose>
   </xsl:template>
   <xsl:template match="tei:typeDesc">
      <xsl:choose>
         <xsl:when test="tei:typeNote/@medium = 'schreibmaschine'">
            <xsl:text>Schreibmaschine</xsl:text>
         </xsl:when>
         <xsl:when test="tei:typeNote/@medium = 'maschinell'">
            <xsl:text>maschinell</xsl:text>
         </xsl:when>
         <xsl:when test="tei:typeNote/@medium = 'druck'">
            <xsl:text>Druck</xsl:text>
         </xsl:when>
         <xsl:when test="tei:typeNote/@medium = 'anderes'">
            <xsl:apply-templates/>
         </xsl:when>
      </xsl:choose>
      <xsl:apply-templates/>
   </xsl:template>
   <xsl:template match="tei:typeDesc/tei:p">
      <xsl:apply-templates/>
   </xsl:template>
   <xsl:template match="tei:handDesc">
      <xsl:choose>
         <!-- Nur eine Handschrift, diese demnach vom Autor/der Autorin: -->
         <xsl:when
            test="not(child::tei:handNote[2]) and (not(child::tei:handNote/@corresp) or tei:handNote[1]/@corresp = ancestor::tei:TEI/tei:teiHeader[1]/tei:fileDesc[1]/tei:titleStmt[1][not(child::tei:author[2])]/tei:author[1]/@ref)">
            <xsl:text>Handschrift: </xsl:text>
            <xsl:value-of select="foo:handNote(tei:handNote)"/>
         </xsl:when>
         <!-- Der Hauptautor, aber mit mehr Schriften -->
         <xsl:when
            test="count(distinct-values(tei:handNote/@corresp)) = 1 and tei:handNote[1]/@corresp = ancestor::tei:TEI/tei:teiHeader[1]/tei:fileDesc[1]/tei:titleStmt[1][not(child::tei:author[2])]/tei:author[1]/@ref">
            <xsl:variable name="handDesc-v" select="current()"/>
            <xsl:for-each select="distinct-values(tei:handNote/@corresp)">
               <xsl:variable name="corespi" select="replace(., '#', '')"/>
               <xsl:text>Handschrift: </xsl:text>
               <xsl:choose>
                  <xsl:when test="count($handDesc-v/tei:handNote[@corresp = $corespi]) = 1">
                     <xsl:value-of
                        select="foo:handNote($handDesc-v/tei:handNote[@corresp = $corespi])"/>
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:for-each select="$handDesc-v/tei:handNote[@corresp = $corespi]">
                        <xsl:variable name="poschitzon" select="position()"/>
                        <xsl:value-of select="$poschitzon"/>
                        <xsl:text>)&#160;</xsl:text>
                        <xsl:value-of select="foo:handNote(current())"/>
                        <xsl:text>\hspace{1em}</xsl:text>
                     </xsl:for-each>
                  </xsl:otherwise>
               </xsl:choose>
               <xsl:if test="not(position() = last())">
                  <xsl:text>&#10;\newline{}</xsl:text>
               </xsl:if>
            </xsl:for-each>
         </xsl:when>
         <!-- Nur eine Handschrift, diese nicht vom Autor/der Autorin: -->
         <xsl:when test="not(child::tei:handNote[2]) and (tei:handNote/@corresp)">
            <xsl:text>Handschrift </xsl:text>
            <xsl:choose>
               <xsl:when test="tei:handNote/@corresp = 'schreibkraft'">
                  <xsl:text>einer Schreibkraft: </xsl:text>
                  <xsl:value-of select="foo:handNote(tei:handNote)"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:variable name="coorespi-name"
                     select="key('person-lookup', (tei:handNote/@corresp), $persons)[1]/tei:persName[1]"
                     as="node()?"/>
                  <xsl:value-of
                     select="concat($coorespi-name/tei:forename, ' ', $coorespi-name/tei:surname)"/>
                  <xsl:text>: </xsl:text>
                  <xsl:value-of select="foo:handNote(tei:handNote)"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:when>
         <xsl:otherwise>
            <xsl:variable name="handDesc-v" select="current()"/>
            <xsl:for-each select="distinct-values(tei:handNote/@corresp)">
               <xsl:variable name="corespi" select="replace(., '#', '')"/>
               <xsl:variable name="corespi-name"
                  select="key('person-lookup', ($corespi[1]), $persons)[1]/tei:persName[1]"
                  as="node()?"/>
               <xsl:text>Handschrift </xsl:text>
               <xsl:choose>
                  <xsl:when test=". = 'schreibkraft'">
                     <xsl:text>Schreibkraft</xsl:text>
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:value-of
                        select="concat($corespi-name/tei:forename, ' ', $corespi-name/tei:surname)"
                     />
                  </xsl:otherwise>
               </xsl:choose>
               <xsl:text>: </xsl:text>
               <xsl:choose>
                  <xsl:when test="count($handDesc-v/tei:handNote[@corresp = $corespi]) = 1">
                     <xsl:value-of
                        select="foo:handNote($handDesc-v/tei:handNote[@corresp = $corespi])"/>
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:for-each select="$handDesc-v/tei:handNote[@corresp = $corespi]">
                        <xsl:variable name="poschitzon" select="position()"/>
                        <xsl:value-of select="$poschitzon"/>
                        <xsl:text>)&#160;</xsl:text>
                        <xsl:value-of select="foo:handNote(current())"/>
                        <xsl:text>\hspace{1em}</xsl:text>
                     </xsl:for-each>
                  </xsl:otherwise>
               </xsl:choose>
               <xsl:if test="not(position() = last())">
                  <xsl:text>&#10;\newline{}</xsl:text>
               </xsl:if>
            </xsl:for-each>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:function name="foo:handNote">
      <xsl:param name="entry" as="node()"/>
      <xsl:choose>
         <xsl:when test="$entry/@medium = 'bleistift'">
            <xsl:text>Bleistift</xsl:text>
         </xsl:when>
         <xsl:when test="$entry/@medium = 'roter-buntstift'">
            <xsl:text>roter Buntstift</xsl:text>
         </xsl:when>
         <xsl:when test="$entry/@medium = 'blauer-buntstift'">
            <xsl:text>blauer Buntstift</xsl:text>
         </xsl:when>
         <xsl:when test="$entry/@medium = 'gruener-buntstift'">
            <xsl:text>grüner Buntstift</xsl:text>
         </xsl:when>
         <xsl:when test="$entry/@medium = 'schwarze-tinte'">
            <xsl:text>schwarze Tinte</xsl:text>
         </xsl:when>
         <xsl:when test="$entry/@medium = 'blaue-tinte'">
            <xsl:text>blaue Tinte</xsl:text>
         </xsl:when>
         <xsl:when test="$entry/@medium = 'gruene-tinte'">
            <xsl:text>grüne Tinte</xsl:text>
         </xsl:when>
         <xsl:when test="$entry/@medium = 'rote-tinte'">
            <xsl:text>rote Tinte</xsl:text>
         </xsl:when>
         <xsl:when test="$entry/@medium = 'lila-tinte'">
            <xsl:text>lila Tinte</xsl:text>
         </xsl:when>
         <xsl:when test="$entry/@medium = 'anderes'">
            <xsl:text>anderes Schreibmittel</xsl:text>
         </xsl:when>
      </xsl:choose>
      <xsl:if test="not($entry/@style = 'nicht-anzuwenden')">
         <xsl:text>, </xsl:text>
      </xsl:if>
      <xsl:choose>
         <xsl:when test="$entry/@style = 'deutsche-kurrent'">
            <xsl:text>deutsche Kurrent</xsl:text>
         </xsl:when>
         <xsl:when test="$entry/@style = 'lateinische-kurrent'">
            <xsl:text>lateinische Kurrent</xsl:text>
         </xsl:when>
         <xsl:when test="$entry/@style = 'gabelsberger'">
            <xsl:text>Gabelsberger Kurzschrift</xsl:text>
         </xsl:when>
      </xsl:choose>
      <xsl:if test="string-length(normalize-space($entry/.)) &gt; 1">
         <xsl:text> (</xsl:text>
         <xsl:apply-templates select="$entry"/>
         <xsl:text>)</xsl:text>
      </xsl:if>
   </xsl:function>
   <xsl:template match="tei:physDesc">
      <xsl:text>&#10;\physDesc{</xsl:text>
      <xsl:choose>
         <xsl:when
            test="(ancestor::tei:witness/tei:objectType or child::tei:objectDesc) and (child::tei:typeDesc or child::tei:handDesc or child::tei:additions)">
            <xsl:choose>
               <xsl:when test="ancestor::tei:witness/tei:objectType and child::tei:objectDesc">
                  <xsl:apply-templates select="ancestor::tei:witness/tei:objectType" mode="physdesc"/>
                  <xsl:if
                     test="child::tei:objectDesc/tei:supportDesc/tei:extent/tei:measure[2] or child::tei:objectDesc/tei:supportDesc/child::tei:*[not(name() = 'extent')]">
                     <xsl:text>, </xsl:text>
                  </xsl:if>
                  <xsl:apply-templates select="child::tei:objectDesc"/>
               </xsl:when>
               <xsl:when test="child::tei:objectDesc">
                  <xsl:apply-templates select="child::tei:objectDesc"/>
               </xsl:when>
            </xsl:choose>
            <xsl:if
               test="(ancestor::tei:witness/tei:objectType or child::tei:objectDesc) and child::tei:*[not(name() = 'objectDesc')]">
               <xsl:text>&#10;\newline{}</xsl:text>
            </xsl:if>
            <xsl:if test="tei:typeDesc">
               <xsl:apply-templates select="tei:typeDesc"/>
               <xsl:if test="tei:handDesc">
                  <xsl:text>&#10;\newline{}</xsl:text>
               </xsl:if>
            </xsl:if>
            <xsl:if test="tei:handDesc">
               <xsl:apply-templates select="tei:handDesc"/>
            </xsl:if>
            <xsl:if test="tei:additions">
               <xsl:apply-templates select="tei:additions"/>
            </xsl:if>
         </xsl:when>
         <xsl:when test="child::tei:p">
            <xsl:apply-templates/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>XXXX PHYSDESC FEHLER</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:text>}</xsl:text>
   </xsl:template>
   <xsl:template match="tei:objectType"/>
   <xsl:template match="tei:objectType" mode="physdesc">
      <!-- VVV -->
      <xsl:choose>
         <xsl:when test="text() != ''">
            <!-- für den Fall, dass Textinhalt, wird einfach dieser ausgegeben -->
            <xsl:value-of select="normalize-space(.)"/>
         </xsl:when>
         <xsl:when test="@ana">
            <xsl:choose>
               <xsl:when test="@ana = 'fotografie'">
                  <xsl:text>Fotografie</xsl:text>
               </xsl:when>
               <xsl:when test="@ana = 'entwurf' and @corresp = 'brief'">
                  <xsl:text>Briefentwurf</xsl:text>
               </xsl:when>
               <xsl:when test="@ana = 'entwurf' and @corresp = 'telegramm'">
                  <xsl:text>Telegrammentwurf</xsl:text>
               </xsl:when>
               <xsl:when test="@ana = 'bildpostkarte'">
                  <xsl:text>Bildpostkarte</xsl:text>
               </xsl:when>
               <xsl:when test="@ana = 'postkarte'">
                  <xsl:text>Postkarte</xsl:text>
               </xsl:when>
               <xsl:when test="@ana = 'briefkarte'">
                  <xsl:text>Briefkarte</xsl:text>
               </xsl:when>
               <xsl:when test="@ana = 'visitenkarte'">
                  <xsl:text>Visitenkarte</xsl:text>
               </xsl:when>
               <xsl:when test="@corresp = 'widmung'">
                  <xsl:choose>
                     <xsl:when test="@ana = 'widmung_vorsatzblatt'">
                        <xsl:text>Widmung am Vorsatzblatt</xsl:text>
                     </xsl:when>
                     <xsl:when test="@ana = 'widmung_titetei:lblatt'">
                        <xsl:text>Widmung am Titetei:lblatt</xsl:text>
                     </xsl:when>
                     <xsl:when test="@ana = 'widmung_schmutztitel'">
                        <xsl:text>Widmung am Schmutztitel</xsl:text>
                     </xsl:when>
                     <xsl:when test="@ana = 'widmung_umschlag'">
                        <xsl:text>Widmung am Umschlag</xsl:text>
                     </xsl:when>
                  </xsl:choose>
               </xsl:when>
            </xsl:choose>
         </xsl:when>
         <!-- ab hier ist nurmehr @corresp zu berücksichtigen, alle @ana-Fälle sind erledigt -->
         <xsl:when test="@corresp = 'anderes'">
            <xsl:text>Sonderfall</xsl:text>
         </xsl:when>
         <xsl:when test="@corresp = 'bild'">
            <xsl:text>Bild</xsl:text>
         </xsl:when>
         <xsl:when test="@corresp = 'brief'">
            <xsl:text>Brief</xsl:text>
         </xsl:when>
         <xsl:when test="@corresp = 'karte'">
            <xsl:text>Karte</xsl:text>
         </xsl:when>
         <xsl:when test="@corresp = 'kartenbrief'">
            <xsl:text>Kartenbrief</xsl:text>
         </xsl:when>
         <xsl:when test="@corresp = 'telegramm'">
            <xsl:text>Telegramm</xsl:text>
         </xsl:when>
         <xsl:when test="@corresp = 'kuvert'">
            <xsl:text>Kuvert</xsl:text>
         </xsl:when>
         <xsl:when test="@corresp = 'widmung'">
            <xsl:text>Widmung</xsl:text>
         </xsl:when>
      </xsl:choose>
   </xsl:template>
   <xsl:template match="tei:objectDesc">
      <!-- VVV -->
      <xsl:if test="@form">
         <xsl:choose>
            <xsl:when test="@form = 'durchschlag'">
               <xsl:text>Durchschlag, </xsl:text>
            </xsl:when>
            <xsl:when test="@form = 'fotografische_vervielfaeltigung'">
               <xsl:text>fotografische Vervielfältigung, </xsl:text>
            </xsl:when>
            <xsl:when test="@form = 'fotokopie'">
               <xsl:text>Fotokopie, </xsl:text>
            </xsl:when>
            <xsl:when test="@form = 'hs_abschrift'">
               <xsl:text>handschriftliche Abschrift. </xsl:text>
            </xsl:when>
            <xsl:when test="@form = 'ms_abschrift'">
               <xsl:text>maschinenschriftliche Abschrift, </xsl:text>
            </xsl:when>
         </xsl:choose>
      </xsl:if>
      <xsl:if test="@form and supportDesc">
         <xsl:text>, </xsl:text>
      </xsl:if>
      <xsl:apply-templates select="tei:supportDesc"/>
   </xsl:template>
   <xsl:template match="tei:supportDesc">
      <xsl:apply-templates select="tei:extent"/>
      <xsl:if test="tei:support">
         <xsl:apply-templates select="tei:support"/>
      </xsl:if>
      <xsl:if test="tei:condition">
         <xsl:choose>
            <xsl:when test="tei:condition/@ana = 'fragment'">
               <xsl:text>, Fragment</xsl:text>
               <xsl:if test=". != ''">
                  <xsl:text> (</xsl:text>
                  <xsl:value-of select="tei:condition"/>
                  <xsl:text>)</xsl:text>
               </xsl:if>
            </xsl:when>
            <xsl:otherwise>
               <xsl:text>, </xsl:text>
               <xsl:value-of select="tei:condition"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:if>
   </xsl:template>
   <xsl:template match="tei:extent">
      <xsl:variable name="unitOrder"
         select="'blatt seite karte kartenbrief widmung kuvert zeichenanzahl'"/>
      <xsl:variable name="measures" select="." as="node()"/>
      <xsl:for-each select="tokenize($unitOrder, ' ')">
         <xsl:variable name="current" select="."/>
         <xsl:for-each select="$measures/tei:measure[@unit = $current]">
            <xsl:apply-templates select="."/>
            <xsl:variable name="unitOrderRest"
               select="normalize-space(substring-after($unitOrder, $current))" as="xs:string?"/>
            <xsl:if
               test="exists($measures/tei:measure[@unit = tokenize($unitOrderRest, ' ')]) and $measures/tei:measure[not(@unit = 'karte' and @quantity = '1') and not(@unit = 'widmung' and @quantity = '1') and not(@unit = 'kartenbrief' and @quantity = '1')][2]">
               <xsl:text>, </xsl:text>
            </xsl:if>
         </xsl:for-each>
      </xsl:for-each>
   </xsl:template>
   <xsl:template match="tei:measure[@unit = 'seite']">
      <xsl:choose>
         <xsl:when test="@quantity = '1'">
            <xsl:text>1&#160;Seite</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="@quantity"/>
            <xsl:text>&#160;Seiten</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:template match="tei:measure[@unit = 'blatt']">
      <xsl:choose>
         <xsl:when test="@quantity = '1'">
            <xsl:text>1&#160;Blatt</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="@quantity"/>
            <xsl:text>&#160;Blätter</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:template match="tei:measure[@unit = 'kuvert']">
      <xsl:choose>
         <xsl:when test="@quantity = '1'">
            <xsl:text>Kuvert</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="@quantity"/>
            <xsl:text>&#160;Kuverts</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:template match="tei:measure[@unit = 'widmung']">
      <xsl:choose>
         <xsl:when test="@quantity = '1'"/>
         <xsl:otherwise>
            <xsl:value-of select="@quantity"/>
            <xsl:text>&#160;Widmungen</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:template match="tei:measure[@unit = 'kartenbrief']">
      <xsl:choose>
         <xsl:when test="@quantity = '1'"/>
         <xsl:otherwise>
            <xsl:value-of select="@quantity"/>
            <xsl:text>&#160;Kartenbriefe</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:template match="tei:measure[@unit = 'karte']">
      <xsl:choose>
         <xsl:when test="@quantity = '1'"/>
         <xsl:otherwise>
            <xsl:value-of select="@quantity"/>
            <xsl:text>&#160;Karten</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:template match="tei:measure[@unit = 'zeichenanzahl']">
      <xsl:if test="not(parent::tei:extent/tei:measure[2])">
         <xsl:text>, </xsl:text>
      </xsl:if>
      <xsl:value-of select="@quantity"/>
      <xsl:text>&#160;Zeichen</xsl:text>
   </xsl:template>
   <xsl:template match="tei:support">
      <xsl:text> (</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>)</xsl:text>
   </xsl:template>
   <xsl:template match="tei:listBibl">
      <xsl:apply-templates/>
   </xsl:template>
   <xsl:template match="tei:biblStruct">
      <xsl:apply-templates/>
   </xsl:template>
   <xsl:template match="tei:monogr">
      <xsl:apply-templates/>
   </xsl:template>
   <xsl:template match="tei:monogr/tei:author">
      <xsl:apply-templates/>
      <xsl:text>: </xsl:text>
   </xsl:template>
   <xsl:template match="tei:monogr/tei:title[@level = 'm']">
      <xsl:apply-templates/>
      <xsl:text>. </xsl:text>
   </xsl:template>
   <xsl:template match="tei:editor"/>
   <xsl:template match="tei:biblScope[@unit = 'pp']">
      <xsl:text>, S.&#8239;</xsl:text>
      <xsl:apply-templates/>
   </xsl:template>
   <xsl:template match="tei:biblScope[@unit = 'col']">
      <xsl:text>, Sp.&#8239;</xsl:text>
      <xsl:apply-templates/>
   </xsl:template>
   <xsl:template match="tei:biblScope[@unit = 'vol']">
      <xsl:text>, Bd.&#8239;</xsl:text>
      <xsl:apply-templates/>
   </xsl:template>
   <xsl:template match="tei:biblScope[@unit = 'jg']">
      <xsl:text>, Jg.&#8239;</xsl:text>
      <xsl:apply-templates/>
   </xsl:template>
   <xsl:template match="tei:biblScope[@unit = 'nr']">
      <xsl:text>, Nr.&#8239;</xsl:text>
      <xsl:apply-templates/>
   </xsl:template>
   <xsl:template match="tei:biblScope[@unit = 'sec']">
      <xsl:text>, Sec.&#8239;</xsl:text>
      <xsl:apply-templates/>
   </xsl:template>
   <xsl:template match="tei:imprint/tei:date">
      <xsl:text> </xsl:text>
      <xsl:apply-templates/>
   </xsl:template>
   <xsl:template match="tei:imprint/tei:pubPlace">
      <xsl:text> </xsl:text>
      <xsl:apply-templates/>
      <xsl:text>: </xsl:text>
   </xsl:template>
   <xsl:template match="tei:imprint/tei:publisher">
      <xsl:apply-templates/>
   </xsl:template>
   <xsl:template match="tei:stamp">
      <xsl:text>Stempel: »\nobreak{}</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>\nobreak{}«. </xsl:text>
   </xsl:template>
   <xsl:template match="tei:time">
      <xsl:apply-templates/>
   </xsl:template>
   <xsl:template
      match="tei:stamp/tei:placeName | tei:addSpan | tei:stamp/tei:date | tei:stamp/tei:time">
      <xsl:if test="current() != ''">
         <xsl:choose>
            <!--<xsl:when test="self::tei:placeName and @ref = '#pmb50'"/>-->
            <!-- Wien raus -->
            <xsl:when test="self::tei:placeName and ((@ref = '') or empty(@ref))">
               <xsl:text>\textcolor{red}{\textsuperscript{\textbf{KEY}}}</xsl:text>
            </xsl:when>
            <xsl:when test="self::tei:placeName">
               <xsl:variable name="endung" as="xs:string" select="'|pwk}'"/>
               <xsl:value-of
                  select="foo:indexName-Routine('place', replace(tokenize(@ref, ' ')[1], '#', ''), substring-after(@ref, ' '), $endung)"
               />
            </xsl:when>
         </xsl:choose>
         <xsl:choose>
            <xsl:when test="self::tei:date and not(child::tei:*)">
               <xsl:value-of select="foo:date-translate(.)"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:apply-templates/>
            </xsl:otherwise>
         </xsl:choose>
         <xsl:choose>
            <xsl:when test="position() = last()"> </xsl:when>
            <xsl:otherwise>
               <xsl:text>, </xsl:text>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:if>
   </xsl:template>
   <xsl:template match="tei:dateSender/tei:date"/>
   <!-- Autoren in den Index -->
   <xsl:template match="tei:author[not(ancestor::tei:biblStruct)]"/>
   <xsl:template match="tei:correspDesc">
      <xsl:apply-templates/>
   </xsl:template>
   <xsl:template match="tei:listWit">
      <xsl:apply-templates/>
   </xsl:template>
   <xsl:template match="tei:witness">
      <xsl:apply-templates/>
   </xsl:template>
   <xsl:template match="tei:msDesc">
      <xsl:apply-templates/>
   </xsl:template>
   <xsl:template match="tei:msIdentifier">
      <xsl:text>\Standort{</xsl:text>
      <xsl:choose>
         <xsl:when test="tei:settlement = 'Cambridge'">
            <xsl:text>CUL, </xsl:text>
            <xsl:apply-templates select="tei:idno"/>
         </xsl:when>
         <xsl:when test="tei:repository = 'Theatermuseum'">
            <xsl:text>TMW, </xsl:text>
            <xsl:apply-templates select="tei:idno"/>
         </xsl:when>
         <xsl:when test="tei:repository = 'Deutsches Literaturarchiv'">
            <xsl:text>DLA, </xsl:text>
            <xsl:apply-templates select="tei:idno"/>
         </xsl:when>
         <xsl:when test="tei:repository = 'Beinecke Rare Book and Manuscript Library'">
            <xsl:text>YCGL, </xsl:text>
            <xsl:apply-templates select="tei:idno"/>
         </xsl:when>
         <xsl:when test="tei:repository = 'Freies Deutsches Hochstift'">
            <xsl:text>FDH, </xsl:text>
            <xsl:apply-templates select="tei:idno"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:apply-templates/>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:text>}</xsl:text>
   </xsl:template>
   <xsl:template match="tei:msIdentifier/tei:settlement">
      <xsl:choose>
         <xsl:when test="contains(parent::tei:msIdentifier/tei:repository, .)"/>
         <xsl:otherwise>
            <xsl:apply-templates/>
            <xsl:text>, </xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:template match="tei:msIdentifier/tei:repository">
      <xsl:apply-templates/>
      <xsl:text>, </xsl:text>
   </xsl:template>
   <xsl:template match="tei:msIdentifier/tei:idno">
      <xsl:choose>
         <xsl:when test="starts-with(normalize-space(.), 'Yale Collection of German Literature, ')">
            <xsl:value-of
               select="fn:substring-after(normalize-space(.), 'Yale Collection of German Literature, ')"
            />
         </xsl:when>
         <xsl:when test="empty(.) or . = ''">
            <xsl:text>\emph{ohne Signatur}</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="fn:normalize-space(.)"/>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:choose>
         <xsl:when test="ends-with(normalize-space(.), '.')"/>
         <xsl:otherwise>
            <xsl:text>.</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:template match="tei:revisionDesc">
      <xsl:choose>
         <xsl:when test="@status = 'approved'"/>
         <xsl:when test="@status = 'candidate'"/>
         <xsl:when test="@status = 'proposed'"/>
         <xsl:otherwise>
            <xsl:text>\small{}</xsl:text>
            <xsl:text>\subsection*{\textcolor{red}{Status: Angelegt}}</xsl:text>
            <xsl:if test="child::tei:change">
               <xsl:apply-templates/>
            </xsl:if>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:template match="tei:change"/>
   <!--<xsl:value-of select="fn:day-from-date(@when)"/>
      <xsl:text>.&#160;</xsl:text>
      <xsl:value-of select="fn:month-from-date(@when)"/>
      <xsl:text>.&#160;</xsl:text>
      <xsl:value-of select="fn:year-from-date(@when)"/>
      <xsl:apply-templates/>
      <xsl:text>&#10;\newline </xsl:text>
   </xsl:template>-->
   <xsl:template match="tei:front"/>
   <xsl:template match="tei:back"/>
   <xsl:template match="tei:back" mode="tex">
      <xsl:if test="child::tei:listPerson/tei:person[not(@xml:id = 'pmb2121')]">
         <xsl:text>&#10;\renewcommand{\erwaehntePersonen}{</xsl:text>
         <xsl:text>Personen: </xsl:text>
         <xsl:for-each select="
               child::tei:listPerson/tei:person[not(@xml:id = 'pmb2121')]">
            <xsl:sort select="descendant::tei:surname/text()"/>
            <xsl:value-of
               select="concat(descendant::tei:forename/text(), ' ', descendant::tei:surname/text())"/>
            <xsl:if test="position() != last()">
               <xsl:text>, </xsl:text>
            </xsl:if>
         </xsl:for-each>
         <xsl:text>}</xsl:text>
      </xsl:if>
      <xsl:if test="child::tei:listOrg/tei:org">
         <xsl:text>&#10;\renewcommand{\erwaehnteInstitutionen}{</xsl:text>
         <xsl:text>Institutionen: </xsl:text>
         <xsl:for-each select="child::tei:listOrg/tei:org">
            <xsl:sort select="descendant::tei:orgName[1]/text()"/>
            <xsl:value-of
               select="foo:sonderzeichen-ersetzen(normalize-space(descendant::tei:orgName[1]/text()))"/>
            <xsl:if test="position() != last()">
               <xsl:text>, </xsl:text>
            </xsl:if>
         </xsl:for-each>
         <xsl:text>}</xsl:text>
      </xsl:if>
      <xsl:if test="child::tei:listPlace/tei:place">
         <xsl:text>&#10;\renewcommand{\erwaehnteOrte}{</xsl:text>
         <xsl:text>Orte: </xsl:text>
         <xsl:for-each select="child::tei:listPlace/tei:place">
            <xsl:sort select="descendant::tei:placeName[1]/text()"/>
            <xsl:value-of
               select="foo:sonderzeichen-ersetzen(normalize-space(descendant::tei:placeName[1]/text()))"/>
            <xsl:if test="position() != last()">
               <xsl:text>, </xsl:text>
            </xsl:if>
         </xsl:for-each>
         <xsl:text>}</xsl:text>
      </xsl:if>
      <xsl:text>&#10;\renewcommand{\erwaehnteWerke}{</xsl:text>
      <xsl:if test="child::tei:listBibl/bibl">
         <xsl:text>Werke: </xsl:text>
         <xsl:for-each select="child::tei:listBibl/bibl">
            <xsl:sort select="descendant::tei:title[1]/text()"/>
            <xsl:value-of
               select="foo:sonderzeichen-ersetzen(normalize-space(descendant::tei:title[1]/text()))"/>
            <!--<xsl:if test="descendant::tei:date[text()]">
            <xsl:text> (</xsl:text>
            <xsl:value-of select="descendant::tei:date/text()"/>
            <xsl:text>)</xsl:text>
         </xsl:if>-->
            <xsl:if test="position() != last()">
               <xsl:text>, </xsl:text>
            </xsl:if>
         </xsl:for-each>
      </xsl:if>
      <xsl:text>}</xsl:text>
      <xsl:text>&#10;\renewcommand{\erwaehnteEvents}{</xsl:text>
      <xsl:if test="child::tei:listEvent/event">
         <xsl:text>Ereignisse: </xsl:text>
         <xsl:for-each select="child::tei:listEvent/event">
            <xsl:sort select="descendant::tei:eventName[1]/text()"/>
            <xsl:value-of
               select="foo:sonderzeichen-ersetzen(normalize-space(descendant::tei:eventName[1]/text()))"/>
            <xsl:if test="position() != last()">
               <xsl:text>, </xsl:text>
            </xsl:if>
         </xsl:for-each>
      </xsl:if>
      <xsl:text>}</xsl:text>
   </xsl:template>
   <xsl:function name="foo:briefempfaenger-mehrere-persName-rekursiv">
      <xsl:param name="briefempfaenger" as="node()"/>
      <xsl:param name="briefempfaenger-anzahl" as="xs:integer"/>
      <xsl:param name="briefsender" as="node()"/>
      <xsl:param name="date" as="xs:date?"/>
      <xsl:param name="date-n" as="xs:integer"/>
      <xsl:param name="datum" as="xs:string"/>
      <xsl:param name="vorne" as="xs:boolean"/>
      <xsl:value-of select="
            foo:briefempfaenger-rekursiv($briefsender,
            count($briefsender/tei:persName),
            $briefempfaenger/tei:persName[$briefempfaenger-anzahl]/@ref,
            $date,
            $date-n,
            $datum,
            $vorne)"/>
      <xsl:if test="$briefempfaenger-anzahl &gt; 1">
         <xsl:value-of
            select="foo:briefempfaenger-mehrere-persName-rekursiv($briefempfaenger, $briefempfaenger-anzahl - 1, $briefsender, $date, $date-n, $datum, $vorne)"
         />
      </xsl:if>
   </xsl:function>
   <xsl:template match="tei:date">
      <xsl:choose>
         <xsl:when test="child::tei:*">
            <xsl:apply-templates/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="foo:date-translate(.)"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:function name="foo:briefsender-mehrere-persName-rekursiv">
      <xsl:param name="briefsender" as="node()"/>
      <xsl:param name="briefsender-anzahl" as="xs:integer"/>
      <xsl:param name="briefempfaenger" as="node()"/>
      <xsl:param name="date" as="xs:date"/>
      <xsl:param name="date-n" as="xs:integer"/>
      <xsl:param name="datum" as="xs:string"/>
      <xsl:param name="vorne" as="xs:boolean"/>
      <!-- Briefe Schnitzlers an Bahr raus, aber wenn mehrere Absender diese rein -->
      <!-- <xsl:if test="not($briefsender/tei:persName[$briefsender-anzahl]/@ref = '#pmb2121' and $briefempfaenger/tei:persName[1]/@ref='#pmb10815')">
      <xsl:value-of select="foo:briefsender-rekursiv($briefempfaenger, count($briefempfaenger/tei:persName), $briefsender/tei:persName[$briefsender-anzahl]/@ref, $date, $date-n, $datum, $vorne)"/>
     </xsl:if>-->
      <xsl:if test="$briefsender-anzahl &gt; 1">
         <xsl:value-of
            select="foo:briefsender-mehrere-persName-rekursiv($briefsender, $briefsender-anzahl - 1, $briefempfaenger, $date, $date-n, $datum, $vorne)"
         />
      </xsl:if>
   </xsl:function>
   <xsl:function name="foo:seitenzahlen-ordnen">
      <xsl:param name="seitenzahl-vorne" as="xs:integer"/>
      <xsl:param name="seitenzahl-hinten" as="xs:integer"/>
      <xsl:value-of select="format-number($seitenzahl-vorne, '00000')"/>
      <xsl:text>–</xsl:text>
      <xsl:choose>
         <xsl:when test="empty($seitenzahl-hinten)">
            <xsl:text>00000</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="format-number($seitenzahl-hinten, '00000')"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <xsl:function name="foo:quellen-titel-kuerzen">
      <xsl:param name="titel" as="xs:string"/>
      <xsl:choose>
         <xsl:when test="starts-with($titel, 'Tagebuch von Schnitzler')">
            <xsl:value-of select="replace($titel, 'Tagebuch von Schnitzler,', 'Eintrag vom')"/>
         </xsl:when>
         <xsl:when test="contains($titel, 'vor dem 21. 6. 1897')">
            <xsl:value-of select="replace($titel, 'Aufzeichnung von Bahr, ', 'Aufzeichnung, ')"/>
         </xsl:when>
         <xsl:when test="starts-with($titel, 'Tagebuch von Bahr')">
            <xsl:value-of select="replace($titel, 'Tagebuch von Bahr, ', 'Tagebucheintrag vom ')"/>
         </xsl:when>
         <xsl:when test="starts-with($titel, 'Bahr: ')">
            <xsl:value-of select="replace($titel, 'Bahr: ', '')"/>
         </xsl:when>
         <xsl:when test="starts-with($titel, 'Notizheft von Bahr: ')">
            <xsl:value-of select="replace($titel, 'Notizheft von Bahr: ', 'Notizheft, ')"/>
         </xsl:when>
         <xsl:when test="starts-with($titel, 'Kalendereintrag von Bahr, ')">
            <xsl:value-of
               select="replace($titel, 'Kalendereintrag von Bahr, ', 'Kalendereintrag, ')"/>
         </xsl:when>
         <xsl:when test="starts-with($titel, 'Aufzeichnung von Bahr')">
            <xsl:value-of select="replace($titel, 'Aufzeichnung von Bahr, ', 'Aufzeichnung, ')"/>
         </xsl:when>
         <xsl:when test="starts-with($titel, 'Olga Schnitzler: Spiegetei:lbild der Freundschaft')">
            <xsl:value-of
               select="replace($titel, 'Olga Schnitzler: Spiegetei:lbild der Freundschaft, ', '')"/>
         </xsl:when>
         <xsl:when test="starts-with($titel, 'Schnitzler: Leutnant Gustl. Äußere Schicksale,')">
            <xsl:value-of
               select="replace($titel, 'Schnitzler: Leutnant Gustl. Äußere Schicksale, ', 'Leutnant Gustl. Äußere Schicksale, ')"
            />
         </xsl:when>
         <xsl:when test="starts-with($titel, 'Brief an Bahr, Anfang Juli')">
            <xsl:value-of select="replace($titel, 'Schnitzler: ', '')"/>
         </xsl:when>
         <xsl:when test="contains($titel, 'Leseliste')">
            <xsl:value-of select="replace($titel, 'Schnitzler: ', '')"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="$titel"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <xsl:template match="tei:publisher[parent::tei:bibl]">
      <xsl:text>\emph{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
   </xsl:template>
   <xsl:template match="tei:title[parent::tei:bibl]">
      <xsl:text>\emph{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
   </xsl:template>
   <xsl:function name="foo:imprint-in-index">
      <xsl:param name="monogr" as="node()"/>
      <xsl:variable name="imprint" as="node()" select="$monogr/tei:imprint"/>
      <xsl:choose>
         <xsl:when test="$imprint/tei:pubPlace != ''">
            <xsl:value-of select="$imprint/tei:pubPlace" separator=", "/>
            <xsl:choose>
               <xsl:when test="$imprint/tei:publisher != ''">
                  <xsl:text>: \emph{</xsl:text>
                  <xsl:value-of select="$imprint/tei:publisher"/>
                  <xsl:text>}</xsl:text>
                  <xsl:choose>
                     <xsl:when test="$imprint/tei:date != ''">
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="$imprint/tei:date"/>
                     </xsl:when>
                  </xsl:choose>
               </xsl:when>
               <xsl:when test="$imprint/tei:date != ''">
                  <xsl:text>: </xsl:text>
                  <xsl:value-of select="$imprint/tei:date"/>
               </xsl:when>
            </xsl:choose>
         </xsl:when>
         <xsl:otherwise>
            <xsl:choose>
               <xsl:when test="$imprint/tei:publisher != ''">
                  <xsl:value-of select="$imprint/tei:publisher"/>
                  <xsl:choose>
                     <xsl:when test="$imprint/tei:date != ''">
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="$imprint/tei:date"/>
                     </xsl:when>
                  </xsl:choose>
               </xsl:when>
               <xsl:when test="$imprint/tei:date != ''">
                  <xsl:text>(</xsl:text>
                  <xsl:value-of select="$imprint/tei:date"/>
                  <xsl:text>)</xsl:text>
               </xsl:when>
            </xsl:choose>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <xsl:function name="foo:jg-bd-nr">
      <xsl:param name="monogr" as="node()"/>
      <!-- Ist Jahrgang vorhanden, stehts als erstes -->
      <xsl:if test="$monogr//tei:biblScope[@unit = 'jg']">
         <xsl:text>, Jg.&#8239;</xsl:text>
         <xsl:value-of select="$monogr//tei:biblScope[@unit = 'jg']"/>
      </xsl:if>
      <!-- Ist Band vorhanden, stets auch -->
      <xsl:if test="$monogr//tei:biblScope[@unit = 'vol']">
         <xsl:text>, Bd.&#8239;</xsl:text>
         <xsl:value-of select="$monogr//tei:biblScope[@unit = 'vol']"/>
      </xsl:if>
      <!-- Jetzt abfragen, wie viel vom Datum vorhanden: vier Stellen=Jahr, sechs Stellen: Jahr und Monat, acht Stellen: komplettes Datum
              Damit entscheidet sich, wo das Datum platziert wird, vor der Nr. oder danach, oder mit Komma am Schluss -->
      <xsl:choose>
         <xsl:when test="string-length($monogr/tei:imprint/tei:date/@when) = 4">
            <xsl:text> (</xsl:text>
            <xsl:value-of select="$monogr/tei:imprint/tei:date"/>
            <xsl:text>)</xsl:text>
            <xsl:if test="$monogr//tei:biblScope[@unit = 'nr']">
               <xsl:text> Nr.&#8239;</xsl:text>
               <xsl:value-of select="$monogr//tei:biblScope[@unit = 'nr']"/>
            </xsl:if>
         </xsl:when>
         <xsl:when test="string-length($monogr/tei:imprint/tei:date/@when) = 6">
            <xsl:if test="$monogr//tei:biblScope[@unit = 'nr']">
               <xsl:text>, Nr.&#8239;</xsl:text>
               <xsl:value-of select="$monogr//tei:biblScope[@unit = 'nr']"/>
            </xsl:if>
            <xsl:text> (</xsl:text>
            <xsl:value-of select="normalize-space(foo:date-translate($monogr/tei:imprint/tei:date))"/>
            <xsl:text>)</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:if test="$monogr//tei:biblScope[@unit = 'nr']">
               <xsl:text>, Nr.&#8239;</xsl:text>
               <xsl:value-of select="$monogr//tei:biblScope[@unit = 'nr']"/>
            </xsl:if>
            <xsl:if test="$monogr/tei:imprint/tei:date">
               <xsl:text>, </xsl:text>
               <xsl:value-of
                  select="normalize-space(foo:date-translate($monogr/tei:imprint/tei:date))"/>
            </xsl:if>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <xsl:function name="foo:monogr-angabe">
      <xsl:param name="monogr" as="node()"/>
      <xsl:choose>
         <xsl:when test="count($monogr/tei:author) &gt; 0">
            <xsl:value-of
               select="foo:autor-rekursion($monogr, count($monogr/tei:author), count($monogr/tei:author), false(), true())"/>
            <xsl:text>: </xsl:text>
         </xsl:when>
      </xsl:choose>
      <!--   <xsl:choose>
                <xsl:when test="substring($monogr/tei:title/@ref, 1, 3) ='A08' or $monogr/tei:title/@level='j'">-->
      <xsl:text>\emph{</xsl:text>
      <xsl:value-of select="$monogr/tei:title"/>
      <xsl:text>}</xsl:text>
      <!--  </xsl:when>
                <xsl:otherwise>
                   <xsl:value-of select="$monogr/tei:title"/>
                </xsl:otherwise>
             </xsl:choose>-->
      <xsl:if test="$monogr/tei:editor[1]">
         <xsl:text>. </xsl:text>
         <xsl:choose>
            <xsl:when test="$monogr/tei:editor[2]">
               <xsl:text>Herausgegeben von</xsl:text>
               <xsl:for-each select="$monogr/tei:editor">
                  <xsl:text> </xsl:text>
                  <xsl:value-of select="foo:vorname-vor-nachname(.)"/>
                  <xsl:choose>
                     <xsl:when test="position() &lt; last() -1">
                        <xsl:text>, </xsl:text>
                     </xsl:when>
                     <xsl:when test="position() = last() -1">
                        <xsl:text> und </xsl:text>
                     </xsl:when>
                     <xsl:otherwise/>
                     
                  </xsl:choose>
               </xsl:for-each>
            </xsl:when>
            <xsl:when test="$monogr/tei:editor[1]">
               <xsl:choose>
                  <xsl:when test="contains($monogr/tei:editor[1], 'Hrsg') or contains($monogr/tei:editor[1], 'Herausge') or contains($monogr/tei:editor[1], 'herausgeg') or contains($monogr/tei:editor[1], 'Hg.')">
                     <xsl:text> </xsl:text>
                     <xsl:value-of select="$monogr/tei:editor[1]"/>
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:text> Herausgegeben von </xsl:text>
                     <xsl:value-of select="foo:vorname-vor-nachname($monogr/tei:editor[1])"/>
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:when>
         </xsl:choose>
         <xsl:if test="count($monogr/tei:editor/tei:persName/@ref) &gt; 0">
            <xsl:for-each select="$monogr/tei:editor/tei:persName/@ref">
               <xsl:value-of
                  select="foo:person-in-index($monogr/tei:editor/tei:persName/@ref, '|pwk}', true())"/>
            </xsl:for-each>
         </xsl:if>
      </xsl:if>
      <xsl:if test="$monogr/tei:edition">
         <xsl:text>. </xsl:text>
         <xsl:value-of select="$monogr/tei:edition"/>
      </xsl:if>
      <xsl:choose>
         <!-- Hier Abfrage, ob es ein Journal ist -->
         <xsl:when test="$monogr/tei:title[@level = 'j']">
            <xsl:value-of select="foo:jg-bd-nr($monogr)"/>
         </xsl:when>
         <!-- Im anderen Fall müsste es ein 'm' für monographic sein -->
         <xsl:otherwise>
            <xsl:if test="$monogr[child::tei:imprint]">
               <xsl:text>. </xsl:text>
               <xsl:value-of select="foo:imprint-in-index($monogr)"/>
            </xsl:if>
            <xsl:if test="$monogr/tei:biblScope/@unit = 'vol'">
               <xsl:text>, </xsl:text>
               <xsl:value-of select="$monogr/tei:biblScope[@unit = 'vol']"/>
            </xsl:if>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:choose>
         <xsl:when test="$monogr/tei:ref[@type='URL' or @type='DOI']">
            <xsl:for-each select="$monogr/tei:ref[@type='URL' or @type='DOI']">
            <xsl:text> \url{</xsl:text>
               <xsl:value-of select="@target"/>
            <xsl:text>}</xsl:text>
               <xsl:if test="fn:position() != last()">
                  <xsl:text>, </xsl:text>
               </xsl:if>
            </xsl:for-each>
         </xsl:when>
      </xsl:choose>
   </xsl:function>
   <xsl:function name="foo:vorname-vor-nachname" as="xs:string">
      <xsl:param name="name" as="xs:string"/>
      <xsl:variable name="teile" select="tokenize($name, ',')"/>
      <xsl:choose>
         <!-- Nur wenn genau zwei Teile durch genau ein Komma -->
         <xsl:when test="count($teile) = 2">
            <xsl:value-of select="normalize-space(concat($teile[2], ' ', $teile[1]))"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="$name"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <xsl:function name="foo:autor-rekursion">
      <xsl:param name="monogr" as="node()"/>
      <xsl:param name="autor-count" as="xs:integer"/>
      <xsl:param name="autor-count-gesamt" as="xs:integer"/>
      <xsl:param name="keystattwert" as="xs:boolean"/>
      <xsl:param name="vorname-vor-nachname" as="xs:boolean"/>
      <!-- in den Fällen, wo ein Text unter einem Kürzel erschien, wird zum sortieren der key-Wert verwendet -->
      <xsl:variable name="autor" select="$monogr/tei:author"/>
      <xsl:choose>
         <xsl:when
            test="$keystattwert and $monogr/tei:author[$autor-count-gesamt - $autor-count + 1]/@ref">
            <xsl:choose>
               <xsl:when test="$vorname-vor-nachname">
                  <xsl:value-of
                     select="foo:index-sortiert(concat(normalize-space(key('person-lookup', ($monogr/tei:author[$autor-count-gesamt - $autor-count + 1]/@ref), $persons)/tei:persName/tei:forename), ' ', normalize-space(key('person-lookup', ($monogr/tei:author[$autor-count-gesamt - $autor-count + 1]/@ref), $persons)/tei:persName/tei:surname)), 'sc')"
                  />
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of
                     select="foo:index-sortiert(concat(normalize-space(key('person-lookup', ($monogr/tei:author[$autor-count-gesamt - $autor-count + 1]/@ref, $persons)/tei:persName/tei:surname)), ', ', normalize-space(key('person-lookup', ($monogr/tei:author[$autor-count-gesamt - $autor-count + 1]/@ref), $persons)/tei:persName/tei:forename)), 'sc')"
                  />
               </xsl:otherwise>
            </xsl:choose>
         </xsl:when>
         <xsl:otherwise>
            <xsl:choose>
               <xsl:when test="$vorname-vor-nachname">
                  <xsl:value-of
                     select="foo:vorname-vor-nachname($autor[$autor-count-gesamt - $autor-count + 1])"
                  />
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of
                     select="foo:index-sortiert($autor[$autor-count-gesamt - $autor-count + 1], 'sc')"
                  />
               </xsl:otherwise>
            </xsl:choose>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="$autor-count &gt; 1">
         <xsl:text>, </xsl:text>
         <xsl:value-of
            select="foo:autor-rekursion($monogr, $autor-count - 1, $autor-count-gesamt, $keystattwert, $vorname-vor-nachname)"
         />
      </xsl:if>
   </xsl:function>
   <xsl:function name="foo:herausgeber-nach-dem-titel">
      <xsl:param name="monogr" as="node()"/>
      <xsl:if test="$monogr/tei:editor != '' and $monogr/tei:author != ''">
         <xsl:value-of select="$monogr/tei:editor"/>
      </xsl:if>
   </xsl:function>
   <xsl:function name="foo:analytic-angabe">
      <xsl:param name="gedruckte-quellen" as="node()"/>
      <!--  <xsl:param name="vor-dem-at" as="xs:boolean"/> <!-\- Der Parameter ist gesetzt, wenn auch der Sortierungsinhalt vor dem @ ausgegeben werden soll -\->
       <xsl:param name="quelle-oder-literaturliste" as="xs:boolean"/> <!-\- Ists Quelle, kommt der Titel kursiv und der Autor tei:forename Name -\->-->
      <xsl:variable name="analytic" as="node()" select="$gedruckte-quellen/tei:analytic"/>
      <xsl:choose>
         <xsl:when test="$analytic/tei:author[1]/@ref = 'A002003'">
            <xsl:text>[O.&#8239;V.:] </xsl:text>
         </xsl:when>
         <xsl:when test="$analytic/tei:author[1]">
            <xsl:value-of
               select="foo:autor-rekursion($analytic, count($analytic/tei:author), count($analytic/tei:author), false(), true())"/>
            <xsl:text>: </xsl:text>
         </xsl:when>
      </xsl:choose>
      <xsl:choose>
         <xsl:when test="not($analytic/tei:title/@type = 'j')">
            <xsl:text>\emph{</xsl:text>
            <xsl:value-of select="normalize-space(foo:sonderzeichen-ersetzen($analytic/tei:title))"/>
            <xsl:choose>
               <xsl:when test="ends-with(normalize-space($analytic/tei:title), '!')"/>
               <xsl:when test="ends-with(normalize-space($analytic/tei:title), '?')"/>
               <xsl:otherwise>
                  <xsl:text>.</xsl:text>
               </xsl:otherwise>
            </xsl:choose>
            <xsl:text>}</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="normalize-space(foo:sonderzeichen-ersetzen($analytic/tei:title))"/>
            <xsl:choose>
               <xsl:when test="ends-with(normalize-space($analytic/tei:title), '!')"/>
               <xsl:when test="ends-with(normalize-space($analytic/tei:title), '?')"/>
               <xsl:otherwise>
                  <xsl:text>.</xsl:text>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:choose>
         <xsl:when test="$analytic/tei:editor[2]">
            <xsl:text>Herausgegeben von</xsl:text>
            <xsl:for-each select="$analytic/tei:editor">
               <xsl:text> </xsl:text>
               <xsl:value-of select="foo:vorname-vor-nachname(.)"/>
               <xsl:choose>
                  <xsl:when test="position() &lt; last() -1">
                     <xsl:text>, </xsl:text>
                  </xsl:when>
                  <xsl:when test="position() = last() -1">
                     <xsl:text> und </xsl:text>
                  </xsl:when>
                  <xsl:otherwise/>
                     
                  
               </xsl:choose>
            </xsl:for-each>
         </xsl:when>
         <xsl:when test="$analytic/tei:editor[1]">
            <xsl:choose>
               <xsl:when test="contains($analytic/tei:editor[1], 'Hrsg') or contains($analytic/tei:editor[1], 'Herausge') or contains($analytic/tei:editor[1], 'herausgeg') or contains($analytic/tei:editor[1], 'Hg.')">
                  <xsl:text> </xsl:text>
                  <xsl:value-of select="$analytic/tei:editor[1]"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:text> Herausgegeben von </xsl:text>
                  <xsl:value-of select="foo:vorname-vor-nachname($analytic/tei:editor[1])"/>
               </xsl:otherwise>
            </xsl:choose>
            <xsl:text>.</xsl:text>
         </xsl:when>
      </xsl:choose>
      
   </xsl:function>
   
  
   <xsl:function name="foo:nach-dem-rufezeichen">
      <xsl:param name="titel" as="xs:string"/>
      <xsl:param name="gedruckte-quellen" as="node()"/>
      <xsl:param name="gedruckte-quellen-count" as="xs:integer"/>
      <xsl:value-of select="$gedruckte-quellen/ancestor::tei:TEI/@when"/>
      <xsl:text>@</xsl:text>
      <xsl:choose>
         <!-- Hier auszeichnen ob es Archivzeugen gibt -->
         <xsl:when test="boolean($gedruckte-quellen/tei:listWit)">
            <xsl:text>\emph{</xsl:text>
            <xsl:value-of select="foo:quellen-titel-kuerzen($titel)"/>
            <xsl:text>}</xsl:text>
         </xsl:when>
         <xsl:when
            test="$gedruckte-quellen-count = 1 and not(boolean($gedruckte-quellen/tei:listWit))">
            <xsl:text>\emph{\textbf{</xsl:text>
            <xsl:value-of select="foo:quellen-titel-kuerzen($titel)"/>
            <xsl:text>}}</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>\emph{</xsl:text>
            <xsl:value-of select="foo:quellen-titel-kuerzen($titel)"/>
            <xsl:text>}</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:if
         test="not(empty($gedruckte-quellen/tei:listBibl/tei:biblStruct[$gedruckte-quellen-count]/tei:monogr//tei:biblScope[@unit = 'pp']))">
         <xsl:text> (S. </xsl:text>
         <xsl:value-of
            select="$gedruckte-quellen/tei:listBibl/tei:biblStruct[$gedruckte-quellen-count]/tei:monogr//tei:biblScope[@unit = 'pp']"/>
         <xsl:text>)</xsl:text>
      </xsl:if>
   </xsl:function>
   <xsl:function name="foo:vorne-hinten">
      <xsl:param name="vorne" as="xs:boolean"/>
      <xsl:choose>
         <xsl:when test="$vorne">
            <xsl:text>|(</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>|)</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <xsl:function name="foo:weitere-drucke">
      <xsl:param name="gedruckte-quellen" as="node()"/>
      <xsl:param name="anzahl-drucke" as="xs:integer"/>
      <xsl:param name="drucke-zaehler" as="xs:integer"/>
      <xsl:param name="erster-druck-druckvorlage" as="xs:boolean"/>
      <xsl:variable name="seitenangabe" as="xs:string?"
         select="$gedruckte-quellen/tei:biblStruct[$drucke-zaehler]//tei:biblScope[@unit = 'pp'][1]"/>
      <xsl:text>\weitereDrucke{</xsl:text>
      <xsl:if
         test="($anzahl-drucke &gt; 1 and not($erster-druck-druckvorlage)) or ($anzahl-drucke &gt; 2 and $erster-druck-druckvorlage)">
         <xsl:choose>
            <xsl:when test="$erster-druck-druckvorlage">
               <xsl:value-of select="$drucke-zaehler - 1"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="$drucke-zaehler"/>
            </xsl:otherwise>
         </xsl:choose>
         <xsl:text>) </xsl:text>
      </xsl:if>
      <!-- Hier Sigle auskommentiert -->
      <!--<xsl:choose>
         <xsl:when test="$gedruckte-quellen/tei:biblStruct[$drucke-zaehler]/@corresp">
            <xsl:if
               test="not(empty($gedruckte-quellen/tei:biblStruct[$drucke-zaehler]/tei:monogr/tei:title[@level = 'm']/@ref))">
               <xsl:value-of
                  select="foo:werk-indexName-Routine-autoren($gedruckte-quellen/tei:biblStruct[$drucke-zaehler]/tei:monogr/tei:title[@level = 'm']/@ref, '|pwk')"
               />
            </xsl:if>
            <xsl:choose>
               <xsl:when test="empty($seitenangabe)">
                  <xsl:value-of
                     select="foo:sigle-schreiben($gedruckte-quellen/tei:biblStruct[$drucke-zaehler]/@corresp, '')"
                  />
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of
                     select="foo:sigle-schreiben($gedruckte-quellen/tei:biblStruct[$drucke-zaehler]/@corresp, $seitenangabe)"
                  />
               </xsl:otherwise>
            </xsl:choose>
         </xsl:when>
         <xsl:otherwise>-->
      <xsl:choose>
         <xsl:when test="$drucke-zaehler = 1">
            <xsl:value-of
               select="foo:bibliographische-angabe($gedruckte-quellen/tei:biblStruct[$drucke-zaehler], true())"
            />
         </xsl:when>
         <xsl:otherwise>
            <xsl:choose>
               <xsl:when
                  test="$gedruckte-quellen/tei:biblStruct[1]/tei:analytic = $gedruckte-quellen/tei:biblStruct[$drucke-zaehler]">
                  <xsl:value-of
                     select="foo:bibliographische-angabe($gedruckte-quellen/tei:biblStruct[$drucke-zaehler], false())"
                  />
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of
                     select="foo:bibliographische-angabe($gedruckte-quellen/tei:biblStruct[$drucke-zaehler], true())"
                  />
               </xsl:otherwise>
            </xsl:choose>
         </xsl:otherwise>
      </xsl:choose>
      <!-- </xsl:otherwise>
      </xsl:choose>-->
      <xsl:text>} </xsl:text>
      <xsl:if test="$drucke-zaehler &lt; $anzahl-drucke">
         <xsl:value-of
            select="foo:weitere-drucke($gedruckte-quellen, $anzahl-drucke, $drucke-zaehler + 1, $erster-druck-druckvorlage)"
         />
      </xsl:if>
   </xsl:function>
   <!--<xsl:function name="foo:sigle-schreiben">
      <xsl:param name="siglen-wert" as="xs:string"/>
      <xsl:param name="seitenangabe" as="xs:string"/>
      <xsl:variable name="sigle-eintrag" select="key('sigle-lookup', $siglen-wert, $sigle)"
         as="node()?"/>
      <xsl:if
         test="$sigle-eintrag/sigle-vorne and not(normalize-space($sigle-eintrag/sigle-vorne) = '')">
         <xsl:value-of select="$sigle-eintrag/sigle-vorne"/>
         <xsl:text> </xsl:text>
      </xsl:if>
      <xsl:text>\emph{</xsl:text>
      <xsl:value-of select="normalize-space($sigle-eintrag/sigle-mitte)"/>
      <xsl:text>}</xsl:text>
      <xsl:if test="$sigle-eintrag/sigle-hinten">
         <xsl:text> </xsl:text>
         <xsl:value-of select="normalize-space($sigle-eintrag/sigle-hinten)"/>
      </xsl:if>
      <xsl:choose>
         <xsl:when test="(not(normalize-space($sigle-eintrag/sigle-band) = ''))">
            <xsl:text> </xsl:text>
            <xsl:value-of select="normalize-space($sigle-eintrag/sigle-band)"/>
            <xsl:if test="not(empty($seitenangabe) or $seitenangabe = '')">
               <xsl:text>,</xsl:text>
               <xsl:value-of select="$seitenangabe"/>
            </xsl:if>
         </xsl:when>
         <xsl:when test="not(empty($seitenangabe) or $seitenangabe = '')">
            <xsl:text> </xsl:text>
            <xsl:value-of select="$seitenangabe"/>
         </xsl:when>
      </xsl:choose>
      <xsl:text>. </xsl:text>
   </xsl:function>-->
   <!-- Diese Funktion dient dazu, jene Publikationen in die Endnote zu setzen, die als vollständige Quelle wiedergegeben werden, wenn es keine Archivsignatur gibt -->
   <xsl:function name="foo:buchAlsQuelle">
      <xsl:param name="gedruckte-quellen" as="node()"/>
      <xsl:param name="ists-druckvorlage" as="xs:boolean"/>
      <!-- wenn hier true ist, dann wird die erste bibliografische Angabe als Druckvorlage ausgewiesen -->
      <!-- ASI SPEZIAL: NACHDEM DIE QUELLE UNTERHAtei:lb DES FLIESSTEXTES STEHT, WIRD SIE HIER NIE WIEDERGEGEBEN, DRUM NÄCHSTES IF AUSKOMMENTIERT -->
      <xsl:if
         test="($ists-druckvorlage) and not($gedruckte-quellen/tei:biblStruct[1]/@corresp = 'ASTB')">
         <!-- Schnitzlers Tagebuch kommt nicht rein -->
         <xsl:text>\buchAlsQuelle{</xsl:text>
         <!-- Diese Zeile statt der vorigen ist die alte Einstellung, die die bibliografische Angabe in den Anhang schreibt -->
         <!-- <xsl:choose>
               <!-\- Für denn Fall, dass es sich um siglierte Literatur handelt: -\->
               <xsl:when test="$gedruckte-quellen/tei:biblStruct[1]/@corresp">
                  <!-\- Siglierte Literatur -\->
                  <xsl:variable name="seitenangabe" as="xs:string?"
                     select="$gedruckte-quellen/tei:biblStruct[1]/descendant::tei:biblScope[@unit = 'pp']"/>
                  <!-\- Zuerst indizierte Sachen in den Index: -\->
                  <xsl:for-each select="$gedruckte-quellen/tei:biblStruct[1]//tei:title/@ref">
                     <xsl:value-of select="foo:werk-indexName-Routine-autoren(., '|pwk}')"/>
                  </xsl:for-each>
                  <xsl:choose>
                     <!-\- Der Analytic-Teil wird auch bei siglierter Literatur ausgegeben -\->
                     <xsl:when
                        test="not(empty($gedruckte-quellen/tei:biblStruct[1]/tei:analytic)) and empty($seitenangabe)">
                        <xsl:value-of select="foo:analytic-angabe($gedruckte-quellen/tei:biblStruct[1])"/>
                        <xsl:text>In: </xsl:text>
                        <xsl:value-of
                           select="foo:sigle-schreiben($gedruckte-quellen/tei:biblStruct[1]/@corresp, '')"
                        />
                     </xsl:when>
                     <xsl:when
                        test="not(empty($gedruckte-quellen/tei:biblStruct[1]/tei:analytic)) and not(empty($seitenangabe))">
                        <xsl:value-of select="foo:analytic-angabe($gedruckte-quellen/tei:biblStruct[1])"/>
                        <xsl:text>In: </xsl:text>
                        <xsl:value-of
                           select="foo:sigle-schreiben($gedruckte-quellen/tei:biblStruct[1]/@corresp, $seitenangabe)"
                        />
                     </xsl:when>
                     <xsl:when test="empty($seitenangabe)">
                        <xsl:value-of
                           select="foo:sigle-schreiben($gedruckte-quellen/tei:biblStruct[1]/@corresp, '')"
                        />
                     </xsl:when>
                     <xsl:otherwise>
                        <xsl:value-of
                           select="foo:sigle-schreiben($gedruckte-quellen/tei:biblStruct[1]/@corresp, $seitenangabe)"
                        />
                     </xsl:otherwise>
                  </xsl:choose>
               </xsl:when>
               <xsl:otherwise>-->
         <xsl:value-of
            select="foo:bibliographische-angabe($gedruckte-quellen/tei:biblStruct[1], true())"/>
         <!-- </xsl:otherwise>
            </xsl:choose>-->
         <xsl:text>}</xsl:text>
      </xsl:if>
      <xsl:choose>
         <xsl:when
            test="($ists-druckvorlage and $gedruckte-quellen/tei:biblStruct[2]) or (not($ists-druckvorlage) and $gedruckte-quellen/tei:biblStruct[1])">
            <xsl:text>&#10;\buchAbdrucke{</xsl:text>
            <xsl:choose>
               <xsl:when test="$ists-druckvorlage and $gedruckte-quellen/tei:biblStruct[2]">
                  <xsl:value-of
                     select="foo:weitere-drucke($gedruckte-quellen, count($gedruckte-quellen/tei:biblStruct), 2, true())"
                  />
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of
                     select="foo:weitere-drucke($gedruckte-quellen, count($gedruckte-quellen/tei:biblStruct), 1, false())"
                  />
               </xsl:otherwise>
            </xsl:choose>
            <xsl:text>}</xsl:text>
         </xsl:when>
      </xsl:choose>
   </xsl:function>
   <xsl:function name="foo:bibliographische-angabe">
      <xsl:param name="biblstruct" as="node()"/>
      <xsl:param name="mit-analytic" as="xs:boolean"/>
      <!-- Wenn mehrere Abdrucke und da der analytic-Teil gleich, dann braucht der nicht wiederholt werden, dann mit-analytic -->
      <!-- Zuerst das in den Index schreiben von Autor, Zeitschrift etc. -->
      <xsl:for-each select="$biblstruct//tei:title/@ref">
         <xsl:value-of select="foo:indexName-Routine('work', replace(., '#', ''), '', '|pwk}')"/>
      </xsl:for-each>
      <xsl:choose>
         <!-- Zuerst Analytic -->
         <xsl:when test="$biblstruct/tei:analytic">
            <xsl:choose>
               <xsl:when test="$mit-analytic">
                  <xsl:value-of select="foo:analytic-angabe($biblstruct)"/>
                  <xsl:text> </xsl:text>
               </xsl:when>
            </xsl:choose>
            <xsl:text>In: </xsl:text>
            <xsl:value-of select="foo:monogr-angabe($biblstruct/tei:monogr[last()])"/>
         </xsl:when>
         <!-- Jetzt abfragen ob mehrere monogr -->
         <xsl:when test="count($biblstruct/tei:monogr) = 2">
            <xsl:value-of select="foo:monogr-angabe($biblstruct/tei:monogr[last()])"/>
            <xsl:text>.&#8239;Band</xsl:text>
            <!-- <xsl:if test="$biblstruct/tei:monogr[last()]/tei:biblScope/@unit='vol'">
                  <xsl:text> </xsl:text>
                  <xsl:value-of select="$biblstruct/tei:monogr[last()]/tei:biblScope[@unit='vol']"/>
               </xsl:if>-->
            <xsl:text>: </xsl:text>
            <xsl:value-of select="foo:monogr-angabe($biblstruct/tei:monogr[1])"/>
         </xsl:when>
         <!-- Ansonsten ist es eine einzelne monogr -->
         <xsl:otherwise>
            <xsl:value-of select="foo:monogr-angabe($biblstruct/tei:monogr[last()])"/>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="not(empty($biblstruct/tei:monogr//tei:biblScope[@unit = 'sec']))">
         <xsl:text>, Sec.&#8239;</xsl:text>
         <xsl:value-of select="$biblstruct/tei:monogr//tei:biblScope[@unit = 'sec']"/>
      </xsl:if>
      <xsl:if test="not(empty($biblstruct/tei:monogr//tei:biblScope[@unit = 'pp']))">
         <xsl:text>, S.&#8239;</xsl:text>
         <xsl:value-of select="$biblstruct/tei:monogr//tei:biblScope[@unit = 'pp']"/>
      </xsl:if>
      <xsl:if test="not(empty($biblstruct/tei:monogr//tei:biblScope[@unit = 'col']))">
         <xsl:text>, Sp.&#8239;</xsl:text>
         <xsl:value-of select="$biblstruct/tei:monogr//tei:biblScope[@unit = 'col']"/>
      </xsl:if>
      <xsl:if test="not(empty($biblstruct/series))">
         <xsl:text> (</xsl:text>
         <xsl:value-of select="$biblstruct/series/tei:title"/>
         <xsl:if test="$biblstruct/tei:series/tei:biblScope">
            <xsl:text>, </xsl:text>
            <xsl:value-of select="$biblstruct/tei:series/tei:biblScope"/>
         </xsl:if>
         <xsl:text>)</xsl:text>
      </xsl:if>
      <xsl:text>.</xsl:text>
   </xsl:function>
   <xsl:function name="foo:mehrere-witnesse">
      <xsl:param name="witness-count" as="xs:integer"/>
      <xsl:param name="witnesse" as="xs:integer"/>
      <xsl:param name="listWitnode" as="node()"/>
      <!-- <xsl:text>\emph{Standort </xsl:text>
      <xsl:value-of select="$witness-count -$witnesse +1"/>
      <xsl:text>:} </xsl:text>-->
      <xsl:apply-templates select="$listWitnode/tei:witness[$witness-count - $witnesse + 1]"/>
      <xsl:if test="$witnesse &gt; 1">
         <!--<xsl:text>\\{}</xsl:text>-->
         <xsl:apply-templates
            select="foo:mehrere-witnesse($witness-count, $witnesse - 1, $listWitnode)"/>
      </xsl:if>
   </xsl:function>
   <xsl:template match="tei:div1">
      <xsl:choose>
         <xsl:when test="position() = 1">
            <xsl:text>\biographical{</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>\biographicalOhne{</xsl:text>
            <!-- Das setzt das kleine Köpfchen nur beim ersten Vorkommen einer biografischen Note -->
         </xsl:otherwise>
      </xsl:choose>
      <xsl:choose>
         <xsl:when test="tei:ref[@type = 'schnitzler-tagebuch']">
            <xsl:text>\emph{Tagebuch}, </xsl:text>
            <xsl:value-of select="
                  format-date(ref[@type = 'schnitzler-tagebuch']/@target,
                  '[D1].&#8239;[M1].&#8239;[Y0001]')"/>
            <xsl:text>: </xsl:text>
         </xsl:when>
         <xsl:when test="tei:ref[@type = 'wienerschnitzler']">
            <xsl:text>\emph{Wiener Schnitzler}, </xsl:text>
            <xsl:value-of select="
                  format-date(ref[@type = 'wienerschnitzler']/@target,
                  '[D1].&#8239;[M1].&#8239;[Y0001]')"/>
            <xsl:text>: </xsl:text>
         </xsl:when>
         <xsl:when test="tei:bibl">
            <xsl:text>\emph{</xsl:text>
            <xsl:apply-templates select="tei:bibl"/>
            <xsl:text>}: </xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>\textcolor{red}{FEHLER QUELLENANGABE}</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:text>»</xsl:text>
      <xsl:choose>
         <xsl:when test="tei:quote/tei:p">
            <xsl:for-each select="tei:quote/tei:p[not(position() = last())]">
               <xsl:apply-templates/>
               <xsl:text>{ / }</xsl:text>
            </xsl:for-each>
            <xsl:apply-templates select="tei:quote/tei:p[(position() = last())]"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:apply-templates select="tei:quote"/>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:text>«</xsl:text>
      <xsl:if test="
            not(substring(normalize-space(tei:quote), string-length(normalize-space(tei:quote)), 1) = '.' or substring(normalize-space(tei:quote), string-length(normalize-space(tei:quote)), 1) = '?' or substring(normalize-space(tei:quote), string-length(normalize-space(tei:quote)), 1) = '!'
            or tei:quote/node()[position() = last()]/self::tei:dots or substring(normalize-space(tei:quote), string-length(normalize-space(tei:quote)) - 1, 2) = '.–')">
         <xsl:text>.</xsl:text>
      </xsl:if>
      <xsl:text>}</xsl:text>
   </xsl:template>
   <!-- eigentlicher Fließtext root -->
   <xsl:template match="tei:body[not(ancestor::tei:TEI[starts-with(@xml:id, 'E_')])]">
      <xsl:variable name="correspAction-date" as="node()">
         <xsl:choose>
            <xsl:when
               test="ancestor::tei:TEI/descendant::tei:correspDesc/tei:correspAction[@type = 'sent']/tei:date">
               <xsl:apply-templates
                  select="ancestor::tei:TEI/descendant::tei:correspDesc/tei:correspAction[@type = 'sent']/tei:date"
               />
            </xsl:when>
            <xsl:otherwise>
               <xsl:text>EDITI</xsl:text>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:variable name="dokument-id" select="ancestor::tei:TEI/@xml:id"/>
      <!-- Hier komplett abgedruckte Texte fett in den Index -->
      <xsl:if
         test="starts-with(ancestor::tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@level = 'a']/@ref, '#pmb')">
         <xsl:value-of
            select="foo:abgedruckte-workNameRoutine(ancestor::tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@level = 'a']/@ref, true())"
         />
      </xsl:if>
      <!-- Hier Briefe bei den Personen in den Personenindex -->
      <xsl:if test="ancestor::tei:TEI[starts-with(@xml:id, 'L')]">
         <xsl:value-of
            select="foo:sender-empfaenger-in-personenindex-rekursiv(ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'sent'], true(), count(ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'sent']/tei:persName))"/>
         <xsl:value-of
            select="foo:sender-empfaenger-in-personenindex-rekursiv(ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'received'], false(), count(ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'received']/tei:persName))"
         />
      </xsl:if>
      <xsl:text>\normalsize\beginnumbering</xsl:text>
      <!-- Hier werden Briefempfänger und Briefsender in den jeweiligen Index gesetzt -->
      <xsl:choose>
         <xsl:when
            test="not(ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'sent']/tei:date/@when)">
            <xsl:choose>
               <xsl:when
                  test="ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'sent']/tei:date/@notBefore">
                  <xsl:value-of
                     select="foo:briefempfaenger-mehrere-persName-rekursiv(ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'received'], count(ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'received']/tei:persName), ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'sent'], ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'sent']/tei:date/@notAfter, ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'sent']/tei:date/@n, ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'sent']/tei:date, true())"/>
                  <xsl:value-of
                     select="foo:briefsender-mehrere-persName-rekursiv(ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'sent'], count(ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'sent']/tei:persName), ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'received'], ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'sent']/tei:date/@notAfter, ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'sent']/tei:date/@n, ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'sent']/tei:date, true())"
                  />
               </xsl:when>
               <xsl:when
                  test="ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'sent']/tei:date/@from">
                  <xsl:value-of
                     select="foo:briefempfaenger-mehrere-persName-rekursiv(ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'received'], count(ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'received']/tei:persName), ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'sent'], ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'sent']/tei:date/@to, ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'sent']/tei:date/@n, ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'sent']/tei:date, true())"/>
                  <xsl:value-of
                     select="foo:briefsender-mehrere-persName-rekursiv(ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'sent'], count(ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'sent']/tei:persName), ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'received'], ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'sent']/tei:date/@to, ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'sent']/tei:date/@n, ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'sent']/tei:date, true())"
                  />
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of
                     select="foo:briefempfaenger-mehrere-persName-rekursiv(ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'received'], count(ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'received']/tei:persName), ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'sent'], ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'sent']/tei:date/@notBefore, ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'sent']/tei:date/@n, ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'sent']/tei:date, true())"/>
                  <xsl:value-of
                     select="foo:briefsender-mehrere-persName-rekursiv(ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'sent'], count(ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'sent']/tei:persName), ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'received'], ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'sent']/tei:date/@notBefore, ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'sent']/tei:date/@n, ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'sent']/tei:date, true())"
                  />
               </xsl:otherwise>
            </xsl:choose>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="
                  foo:briefempfaenger-mehrere-persName-rekursiv(ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'received'],
                  count(ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'received']/tei:persName),
                  ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'sent'],
                  ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'sent']/tei:date/@when,
                  ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'sent']/tei:date/@n,
                  ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'sent']/tei:date,
                  true())"/>
            <xsl:value-of
               select="foo:briefsender-mehrere-persName-rekursiv(ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'sent'], count(ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'sent']/tei:persName), ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'received'], ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'sent']/tei:date/@when, ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'sent']/tei:date/@n, ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'sent']/tei:date, true())"
            />
         </xsl:otherwise>
      </xsl:choose>
      <!-- Das Folgende schreibt Titel in den Anhang zum Kommentar -->
      <!-- Zuerst mal Abstand, ob klein oder groß, je nachdem, ob Archivsignatur und Kommentar war -->
      <xsl:choose>
         <xsl:when
            test="ancestor::tei:TEI/preceding-sibling::tei:TEI[1]/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:listBibl/tei:biblStruct[1]/tei:monogr/tei:imprint/tei:date/xs:integer(substring(@when, 1, 4)) &lt; 1935">
            <xsl:text>&#10;\toendnotes[C]{\medbreak\pagebreak[2]}</xsl:text>
         </xsl:when>
         <xsl:when
            test="ancestor::tei:TEI/preceding-sibling::tei:TEI[1]/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:listWit">
            <xsl:text>&#10;\toendnotes[C]{\medbreak\pagebreak[2]}</xsl:text>
         </xsl:when>
         <xsl:when test="ancestor::tei:TEI/preceding-sibling::tei:TEI[1]/tei:body//*[@subtype]">
            <xsl:text>&#10;\toendnotes[C]{\medbreak\pagebreak[2]}</xsl:text>
         </xsl:when>
         <xsl:when
            test="ancestor::tei:TEI/preceding-sibling::tei:TEI[1]/tei:body//descendant::tei:note[@type = 'commentary' or @type = 'textConst']">
            <xsl:text>&#10;\toendnotes[C]{\medbreak\pagebreak[2]}</xsl:text>
         </xsl:when>
         <xsl:when
            test="ancestor::tei:TEI/preceding-sibling::tei:TEI[1]/tei:body//descendant::tei:div[@type = 'biographical']">
            <xsl:text>&#10;\toendnotes[C]{\medbreak\pagebreak[2]}</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>&#10;\toendnotes[C]{\smallbreak\pagebreak[2]}</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:variable name="correspAction-date"
         select="ancestor::tei:TEI/descendant::tei:correspDesc/tei:correspAction[@type = 'sent']/tei:date"
         as="node()"/>
      <xsl:variable name="dokument-id">
         <xsl:choose>
            <xsl:when test="ancestor::tei:TEI/descendant::tei:correspDesc">
               <xsl:variable name="n" as="xs:string">
                  <xsl:choose>
                     <xsl:when test="string-length($correspAction-date/@n) = 1">
                        <xsl:value-of select="concat('0', $correspAction-date/@n)"/>
                     </xsl:when>
                     <xsl:otherwise>
                        <xsl:value-of select="$correspAction-date/@n"/>
                     </xsl:otherwise>
                  </xsl:choose>
               </xsl:variable>
               <xsl:variable name="when" as="xs:string">
                  <xsl:variable name="whenNotBeforeNotAfter">
                     <xsl:choose>
                        <xsl:when test="$correspAction-date/@when">
                           <xsl:value-of select="$correspAction-date/@when"/>
                        </xsl:when>
                        <xsl:when test="$correspAction-date/@notBefore">
                           <xsl:value-of select="$correspAction-date/@notBefore"/>
                        </xsl:when>
                        <xsl:otherwise>
                           <xsl:value-of select="$correspAction-date/@notAfter"/>
                        </xsl:otherwise>
                     </xsl:choose>
                  </xsl:variable>
                  <xsl:value-of
                     select="concat(substring($whenNotBeforeNotAfter, 1, 4), '-', substring($whenNotBeforeNotAfter, 5, 2), '-', substring($whenNotBeforeNotAfter, 7, 8))"
                  />
               </xsl:variable>
               <xsl:value-of select="concat('L', $when, '_', $n)"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="@xml:id"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <!--<xsl:text>\anhangTitel{</xsl:text>-->
      <!-- Auskommentiert, dafür statt der Seitenangaben den Dateinamen eingefügt: -->
      <!-- <xsl:text>\myrangeref{</xsl:text>
      <xsl:value-of select="concat($dokument-id, 'v')"/>
      <xsl:text>}</xsl:text>
      <xsl:text>{</xsl:text>
      <xsl:value-of select="concat($dokument-id, 'h')"/>
      <xsl:text>}</xsl:text>-->
      <!-- <xsl:value-of select="ancestor::tei:TEI/@xml:id"/>
      <xsl:text> }{</xsl:text>
      
      <xsl:variable name="titel" as="xs:string"
         select="ancestor::tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@level = 'a']"/>
      <xsl:variable name="titel-ohne-datum" as="xs:string"
         select="substring-before($titel, tokenize($titel, ',')[last()])"/>
      <xsl:variable name="datum" as="xs:string"
         select="substring(substring-after($titel, tokenize($titel, ',')[last() - 1]), 2)"/>
      <xsl:value-of select="$titel-ohne-datum"/>
      <xsl:value-of select="foo:date-translate($datum)"/>
      <xsl:text>\nopagebreak}</xsl:text>-->
      <xsl:variable name="quellen" as="node()"
         select="ancestor::tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc"/>
      <!-- Wenn es Adressen gibt, diese in die Endnote -->
      <!--<xsl:text>\datumImAnhang{</xsl:text>
      <xsl:value-of select="foo:monatUndJahrInKopfzeile(ancestor::tei:TEI/@when)"/>
      <xsl:text>}</xsl:text>-->
      <!--       Zuerst mal die Archivsignaturen  
-->
      <xsl:if test="ancestor::tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:listWit">
         <xsl:choose>
            <xsl:when test="count($quellen/tei:listWit/tei:witness) = 1">
               <xsl:apply-templates select="$quellen/tei:listWit/tei:witness[1]"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:apply-templates
                  select="foo:mehrere-witnesse(count($quellen/tei:listWit/tei:witness), count($quellen/tei:listWit/tei:witness), $quellen/tei:listWit)"
               />
            </xsl:otherwise>
         </xsl:choose>
      </xsl:if>
      <!-- Alternativ noch testen, ob es gedruckt wurde -->
      <xsl:if test="$quellen/tei:listBibl">
         <xsl:choose>
            <!--            <!-\- Briefe Schnitzlers an Bahr raus, da gibt es Konkordanz -\->
            <xsl:when test="ancestor::tei:TEI[descendant::tei:correspDesc/tei:correspAction[@type='sent']/tei:persName/@ref='#pmb2121' and descendant::tei:correspDesc/tei:correspAction[@type='received']/tei:persName/@ref='#pmb10815']"></xsl:when>
-->
            <!-- Gibt es kein listWit ist das erste biblStruct die Quelle -->
            <xsl:when
               test="not(ancestor::tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:listWit) and $quellen/tei:listBibl/tei:biblStruct">
               <xsl:value-of select="foo:buchAlsQuelle($quellen/tei:listBibl, true())"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="foo:buchAlsQuelle($quellen/tei:listBibl, false())"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:if>
      <xsl:choose>
         <xsl:when test="$quellen/tei:listBibl/tei:biblStruct/@corresp = 'ASTB'"/>
         <!-- Bei Schnitzler-Tagebuch keinen Abstand zwischen Titelzeile und Kommentar, da der Standort und die Drucke nicht vermerkt werden -->
         <xsl:when test="descendant::tei:note[@type = 'commentary']">
            <xsl:text>\toendnotes[C]{\smallbreak}</xsl:text>
         </xsl:when>
         <xsl:when test="descendant::tei:*[@subtype]">
            <xsl:text>\toendnotes[C]{\smallbreak}</xsl:text>
         </xsl:when>
         <xsl:when test="descendant::tei:note[@type = 'textConst']">
            <xsl:text>\toendnotes[C]{\smallbreak}</xsl:text>
         </xsl:when>
         <xsl:when test="descendant::tei:hi[@rend = 'underline' and (@n &gt; 2)]">
            <xsl:text>\toendnotes[C]{\smallbreak}</xsl:text>
         </xsl:when>
      </xsl:choose>
      <xsl:apply-templates select="child::tei:div | child::tei:image"/>
      <xsl:text>\endnumbering</xsl:text>
      <xsl:if
         test="starts-with(ancestor::tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@level = 'a']/@ref, 'A0')">
         <xsl:value-of
            select="foo:abgedruckte-workNameRoutine(substring(ancestor::tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@level = 'a']/@ref, 1, 7), false())"
         />
      </xsl:if>
      <xsl:if test="ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc">
         <xsl:choose>
            <xsl:when
               test="not(ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'sent']/tei:date/@when)">
               <xsl:choose>
                  <xsl:when
                     test="ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'sent']/tei:date/@notBefore">
                     <xsl:value-of
                        select="foo:briefempfaenger-mehrere-persName-rekursiv(ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'received'], count(ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'received']/tei:persName), ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'sent'], ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'sent']/tei:date/@notBefore, ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'sent']/tei:date/@n, ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'sent']/tei:date, false())"/>
                     <xsl:value-of
                        select="foo:briefsender-mehrere-persName-rekursiv(ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'sent'], count(ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'sent']/tei:persName), ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'received'], ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'sent']/tei:date/@notBefore, ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'sent']/tei:date/@n, ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'sent']/tei:date, false())"
                     />
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:value-of
                        select="foo:briefempfaenger-mehrere-persName-rekursiv(ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'received'], count(ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'received']/tei:persName), ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'sent'], ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'sent']/tei:date/@notAfter, ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'sent']/tei:date/@n, ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'sent']/tei:date, false())"/>
                     <xsl:value-of
                        select="foo:briefsender-mehrere-persName-rekursiv(ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'sent'], count(ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'sent']/tei:persName), ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'received'], ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'sent']/tei:date/@notAfter, ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'sent']/tei:date/@n, ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'sent']/tei:date, false())"
                     />
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of
                  select="foo:briefempfaenger-mehrere-persName-rekursiv(ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'received'], count(ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'received']/tei:persName), ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'sent'], ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'sent']/tei:date/@when, ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'sent']/tei:date/@n, ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'sent']/tei:date, false())"/>
               <xsl:value-of
                  select="foo:briefsender-mehrere-persName-rekursiv(ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'sent'], count(ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'sent']/tei:persName), ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'received'], ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'sent']/tei:date/@when, ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'sent']/tei:date/@n, ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'sent']/tei:date, false())"
               />
            </xsl:otherwise>
         </xsl:choose>
      </xsl:if>
   </xsl:template>
   <!-- Das ist speziell für die Behandlung von Bildern, der eigentliche body für alles andere kommt danach -->
   <xsl:template match="tei:image">
      <xsl:apply-templates/>
   </xsl:template>
   <!-- body und Absätze von Hrsg-Texten -->
   <xsl:template match="tei:body[ancestor::tei:TEI[starts-with(@xml:id, 'E_')]]">
      <xsl:apply-templates/>
   </xsl:template>
   <xsl:template match="tei:p[ancestor::tei:TEI[starts-with(@xml:id, 'E')]]">
      <xsl:apply-templates/>
      <xsl:text>&#10;\par &#10;
      </xsl:text>
   </xsl:template>
   <!-- body -->
   <xsl:template match="tei:div[@type = 'address']/address">
      <xsl:apply-templates/>
      <xsl:text>&#10;{\bigskip}</xsl:text>
   </xsl:template>
   <xsl:template match="tei:lb">
      <xsl:text>{\\}</xsl:text>
      <!--<xsl:text>{\\[\baselineskip]}</xsl:text>-->
   </xsl:template>
   <xsl:template match="tei:lb[parent::tei:item]">
      <xsl:text>{\newline}</xsl:text>
   </xsl:template>
   <xsl:template match="tei:note[@type = 'footnote' and ancestor::tei:text/tei:body]">
      <xsl:text>\footnote{</xsl:text>
      <xsl:for-each select="tei:p">
         <xsl:apply-templates select="."/>
         <xsl:if test="not(position() = last())">\par\noindent </xsl:if>
      </xsl:for-each>
      <xsl:text>}</xsl:text>
   </xsl:template>
   <xsl:template
      match="tei:p[ancestor::tei:TEI[starts-with(@xml:id, 'E_')] and not(child::tei:*[1] = space[@dim] and not(child::tei:*[2]) and (fn:normalize-space(.) = ''))]">
      <xsl:if test="self::tei:p[@rend = 'inline']">
         <xsl:text>&#10;\leftskip=3em{}</xsl:text>
      </xsl:if>
      <xsl:choose>
         <xsl:when test="ancestor::tei:quote[ancestor::tei:physDesc] and not(position() = 1)">
            <xsl:text>{ / }</xsl:text>
         </xsl:when>
         <xsl:when test="not(@rend) and not(preceding-sibling::p[1])">
            <xsl:text>&#10;\noindent{}</xsl:text>
         </xsl:when>
         <xsl:when test="@rend and not(preceding-sibling::p[1]/@rend = @rend)">
            <xsl:text>\noindent{}</xsl:text>
         </xsl:when>
      </xsl:choose>
      <xsl:choose>
         <xsl:when test="@rend = 'center'">
            <xsl:text>&#10;\begin{center}</xsl:text>
         </xsl:when>
         <xsl:when test="@rend = 'right'">
            <xsl:text>&#10;\begin{flushright}</xsl:text>
         </xsl:when>
      </xsl:choose>
      <xsl:apply-templates/>
      <xsl:choose>
         <xsl:when test="@rend = 'center'">
            <xsl:text>\end{center}</xsl:text>
         </xsl:when>
         <xsl:when test="@rend = 'right'">
            <xsl:text>\end{flushright}</xsl:text>
         </xsl:when>
      </xsl:choose>
      <xsl:choose>
         <xsl:when test="not(fn:position() = last())">
            <xsl:text>\par
      </xsl:text>
         </xsl:when>
      </xsl:choose>
      <xsl:if test="self::tei:p[@rend = 'inline']">\leftskip=0em{}</xsl:if>
   </xsl:template>
   <xsl:template match="tei:p">
      <xsl:choose>
         <xsl:when test="ancestor::tei:quote[ancestor::tei:physDesc] and not(position() = 1)">
            <xsl:text>{ / }</xsl:text>
         </xsl:when>
         <xsl:when test="not(@rend) and not(preceding-sibling::p[1])">
            <xsl:text>\noindent{}</xsl:text>
         </xsl:when>
         <xsl:when test="@rend and not(preceding-sibling::p[1]/@rend = @rend)">
            <xsl:text>\noindent{}</xsl:text>
         </xsl:when>
      </xsl:choose>
      <xsl:choose>
         <xsl:when test="@rend = 'center'">
            <xsl:text>\begin{center}</xsl:text>
         </xsl:when>
         <xsl:when test="@rend = 'right'">
            <xsl:text>\begin{flushright}</xsl:text>
         </xsl:when>
      </xsl:choose>
      <xsl:apply-templates/>
      <xsl:choose>
         <xsl:when test="@rend = 'center'">
            <xsl:text>\end{center}</xsl:text>
         </xsl:when>
         <xsl:when test="@rend = 'right'">
            <xsl:text>\end{flushright}</xsl:text>
         </xsl:when>
      </xsl:choose>
   </xsl:template>
   <xsl:template match="tei:seg[parent::tei:seg]">
      <xsl:apply-templates/>
      <xsl:if test="@rend = 'left'">
         <xsl:text>\hfill </xsl:text>
      </xsl:if>
   </xsl:template>
   <xsl:template
      match="tei:p[ancestor::tei:body and not(ancestor::tei:TEI[starts-with(@xml:id, 'E')]) and not(child::tei:space[@dim] and not(child::tei:*[2]) and empty(text())) and not(ancestor::tei:div[@type = 'biographical']) and not(parent::tei:note[@type = 'footnote'])] | tei:closer | tei:dateline | tei:seg[not(parent::tei:seg)]">
      <!--     <xsl:if test="self::tei:closer">\leftskip=1em{}</xsl:if>
-->
      <xsl:if test="self::tei:p[@rend = 'inline']">
         <xsl:text>\leftskip=3em{}</xsl:text>
      </xsl:if>
      <xsl:choose>
         <xsl:when test="tei:table"/>
         <xsl:when test="tei:textkonstitution/zu-anmerken/tei:table"/>
         <xsl:when
            test="ancestor::tei:quote[ancestor::tei:note] | ancestor::tei:quote[ancestor::tei:physDesc]">
            <xsl:if test="not(position() = 1)">
               <xsl:text>{ / }</xsl:text>
            </xsl:if>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>&#10;\pstart
           </xsl:text>
            <xsl:choose>
               <xsl:when test="self::tei:p and position() = 1">
                  <xsl:text>\noindent{}</xsl:text>
               </xsl:when>
               <xsl:when test="self::tei:p and preceding-sibling::*[1] = preceding-sibling::head[1]">
                  <xsl:text>\noindent{}</xsl:text>
               </xsl:when>
               <xsl:when test="parent::tei:div[child::tei:*[1]] = self::tei:p">
                  <xsl:text>\noindent{}</xsl:text>
               </xsl:when>
               <xsl:when
                  test="self::tei:p and preceding-sibling::*[1] = preceding-sibling::p[@rend = 'right' or @rend = 'center']">
                  <xsl:text>\noindent{}</xsl:text>
               </xsl:when>
               <xsl:when
                  test="self::tei:p[not(@rend = 'inline')] and preceding-sibling::*[1] = preceding-sibling::p[@rend = 'inline']">
                  <xsl:text>\noindent{}</xsl:text>
               </xsl:when>
               <xsl:when
                  test="self::tei:p[preceding-sibling::*[1][self::tei:p[(descendant::tei:*[1] = space[@dim = 'vertical']) and not(descendant::tei:*[2]) and empty(text())]]]">
                  <xsl:text>\noindent{}</xsl:text>
               </xsl:when>
               <xsl:when
                  test="self::tei:p[@rend = 'inline'] and (preceding-sibling::*[1]/not(@rend = 'inline') or preceding-sibling::*[1]/not(@rend))">
                  <xsl:text>\noindent{}</xsl:text>
               </xsl:when>
               <xsl:when
                  test="ancestor::tei:body[child::tei:div[@type = 'original'] and child::tei:div[@type = 'translation']] and not(ancestor::tei:div[@type = 'biographical'] or ancestor::tei:note)">
                  <xsl:text>\einruecken{}</xsl:text>
               </xsl:when>
            </xsl:choose>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:choose>
         <!-- Das hier dient dazu, leere Zeilen, Zeilen mit Trennstrich und weggelassene Absätze (Zeile mit Absatzzeichen in eckiger Klammer) nicht in der Zeilenzählung zu berücksichtigen  -->
         <xsl:when
            test="string-length(normalize-space(self::tei:*)) = 0 and child::tei:*[1] = space[@unit = 'chars' and @quantity = '1'] and not(child::tei:*[2])">
            <xsl:text>\numberlinefalse{}</xsl:text>
         </xsl:when>
         <xsl:when
            test="string-length(normalize-space(self::tei:*)) = 1 and node() = '–' and not(child::tei:*)">
            <xsl:text>\numberlinefalse{}</xsl:text>
         </xsl:when>
         <xsl:when test="tei:missing-paragraph">
            <xsl:text>\numberlinefalse{}</xsl:text>
         </xsl:when>
      </xsl:choose>
      <xsl:choose>
         <xsl:when test="tei:table"/>
         <xsl:when test="tei:closer"/>
         <xsl:when test="tei:postcript"/>
      </xsl:choose>
      <xsl:if test="@rend">
         <xsl:value-of select="foo:absatz-position-vorne(@rend)"/>
      </xsl:if>
      <xsl:choose>
         <xsl:when test="tei:missing-paragraph">
            <xsl:text>\noindent{[}{&#8239;\footnotesize\textparagraph\normalsize&#8239;}{]}</xsl:text>
         </xsl:when>
      </xsl:choose>
      <xsl:apply-templates/>
      <xsl:if test="@rend">
         <xsl:value-of select="foo:absatz-position-hinten(@rend)"/>
      </xsl:if>
      <xsl:if test="ancestor::tei:TEI[starts-with(@xml:id, 'L')]">
         <xsl:value-of
            select="foo:sender-empfaenger-in-personenindex-rekursiv(ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'sent'], true(), count(ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'sent']/tei:persName))"/>
         <xsl:value-of
            select="foo:sender-empfaenger-in-personenindex-rekursiv(ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'received'], false(), count(ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'received']/tei:persName))"
         />
      </xsl:if>
      <xsl:choose>
         <!-- Das hier dient dazu, leere Zeilen, Zeilen mit Trennstrich und weggelassene Absätze (Zeile mit Absatzzeichen in eckiger Klammer) nicht in der Zeilenzählung zu berücksichtigen  -->
         <xsl:when
            test="string-length(normalize-space(self::tei:*)) = 0 and child::tei:*[1] = space[@unit = 'chars' and @quantity = '1'] and not(child::tei:*[2])">
            <xsl:text>\numberlinetrue{}</xsl:text>
         </xsl:when>
         <xsl:when
            test="string-length(normalize-space(self::tei:*)) = 1 and node() = '–' and not(child::tei:*)">
            <xsl:text>\numberlinetrue{}</xsl:text>
         </xsl:when>
         <xsl:when test="tei:missing-paragraph">
            <xsl:text>\numberlinetrue{}</xsl:text>
         </xsl:when>
      </xsl:choose>
      <xsl:choose>
         <xsl:when test="tei:table"/>
         <xsl:when test="tei:textkonstitution/zu-anmerken/tei:table"/>
         <xsl:when
            test="ancestor::tei:quote[ancestor::tei:note] | ancestor::tei:quote[ancestor::tei:physDesc]"/>
         <xsl:otherwise>
            <xsl:text>\pend
           </xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="self::tei:closer | self::tei:p[@rend = 'inline']">\leftskip=0em{}</xsl:if>
   </xsl:template>
   <!-- <xsl:template match="tei:opener/tei:p|tei:dateline">
      <xsl:text>&#10;\pstart</xsl:text>
      <xsl:choose>
         <xsl:when test="@rend='right'">
            <xsl:text>\raggedleft</xsl:text>
         </xsl:when>
         <xsl:when test="@rend='center'">
            <xsl:text>\center</xsl:text>
         </xsl:when>
      </xsl:choose>
      <xsl:text>{}</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>\pend</xsl:text>
   </xsl:template>-->
   <xsl:template match="tei:salute[parent::tei:opener]">
      <xsl:text>&#10;\pstart</xsl:text>
      <xsl:choose>
         <xsl:when test="@rend = 'right'">
            <xsl:text>\raggedleft</xsl:text>
         </xsl:when>
         <xsl:when test="@rend = 'center'">
            <xsl:text>\center</xsl:text>
         </xsl:when>
      </xsl:choose>
      <xsl:text>{}</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>\pend</xsl:text>
   </xsl:template>
   <xsl:template match="tei:salute">
      <xsl:apply-templates/>
   </xsl:template>
   <xsl:function name="foo:tabellenspalten">
      <xsl:param name="spaltenanzahl" as="xs:integer"/>
      <xsl:text>l</xsl:text>
      <xsl:if test="$spaltenanzahl &gt; 1">
         <xsl:value-of select="foo:tabellenspalten($spaltenanzahl - 1)"/>
      </xsl:if>
   </xsl:function>
   <xsl:template match="tei:closer[not(child::tei:lb)]">
      <xsl:text>\pstart <!--\raggedleft\hspace{1em}--></xsl:text>
      <xsl:apply-templates/>
      <xsl:text>\pend{}</xsl:text>
   </xsl:template>
   <xsl:template match="tei:closer/tei:lb">
      <xsl:choose>
         <xsl:when test="following-sibling::*[1] = signed">
            <xsl:apply-templates/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>{\\[\baselineskip]}</xsl:text>
            <xsl:apply-templates/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <!--  <xsl:template match="tei:closer/tei:lb[not(last())]">
      <xsl:text>{\\[\baselineskip]}</xsl:text>
      <xsl:apply-templates/>
   </xsl:template>
   
   <xsl:template match="tei:closer/tei:lb[last()][following-sibling::signed]">
<xsl:choose>
   <xsl:when test="not(following-sibling::node()[not(self::tei:signed)])">
      <xsl:apply-templates/>
   </xsl:when>
   <xsl:otherwise>
      <xsl:text>{\\[\baselineskip]}</xsl:text>
      <xsl:apply-templates/>
   </xsl:otherwise>
</xsl:choose>
   </xsl:template>
   
   <xsl:template match="tei:closer/tei:lb[last()][not(following-sibling::signed)]">
      <!-\-      <xsl:text>\pend\pstart\raggedleft\hspace{1em}</xsl:text>
-\->      <xsl:text>{\\[\baselineskip]}</xsl:text>
      <xsl:apply-templates/>
   </xsl:template>
   -->
   <xsl:template match="tei:*" mode="no-comments">
      <xsl:value-of select="text()"/>
   </xsl:template>
   <xsl:template name="foo:laengsterTextInSpalte">
      <!-- das gibt den längsten text in einer spalte aus -->
      <xsl:param name="spalte" as="node()?"/>
      <xsl:variable name="zelleOhneNote" as="node()?">
         <column>
            <xsl:for-each select="$spalte//tei:cell">
               <cell>
                  <xsl:for-each select="descendant::text()[not(ancestor-or-self::tei:note)]">
                     <xsl:value-of select="normalize-space(.)"/>
                     <xsl:if test="ends-with(., ' ')">
                        <xsl:text>x</xsl:text>
                     </xsl:if>
                  </xsl:for-each>
                  <xsl:for-each select="descendant::tei:c[not(ancestor-or-self::tei:note)]">
                     <xsl:text>m</xsl:text>
                  </xsl:for-each>
                  <xsl:for-each select="descendant::tei:space[not(ancestor-or-self::tei:note)]">
                     <xsl:text>m</xsl:text>
                  </xsl:for-each>
               </cell>
            </xsl:for-each>
         </column>
      </xsl:variable>
      <xsl:variable name="sorted-cells" as="element(cell)*">
         <xsl:perform-sort select="$zelleOhneNote//cell">
            <xsl:sort select="string-length(.)"/>
         </xsl:perform-sort>
      </xsl:variable>
      <xsl:value-of select="$sorted-cells[last()]"/>
   </xsl:template>
   <xsl:template match="tei:table">
      <xsl:variable name="spalte1" as="node()">
         <row>
            <xsl:for-each select="descendant::tei:row/tei:cell[1]">
               <xsl:copy-of select="."/>
            </xsl:for-each>
         </row>
      </xsl:variable>
      <xsl:variable name="spalte2" as="node()">
         <row>
            <xsl:for-each select="descendant::tei:row/tei:cell[2]">
               <xsl:copy-of select="."/>
            </xsl:for-each>
         </row>
      </xsl:variable>
      <xsl:variable name="spalte3" as="node()">
         <row>
            <xsl:for-each select="descendant::tei:row/tei:cell[3]">
               <xsl:copy-of select="."/>
            </xsl:for-each>
         </row>
      </xsl:variable>
      <xsl:variable name="spalte4" as="node()">
         <row>
            <xsl:for-each select="descendant::tei:row/tei:cell[4]">
               <xsl:copy-of select="."/>
            </xsl:for-each>
         </row>
      </xsl:variable>
      <xsl:variable name="spalte5" as="node()">
         <row>
            <xsl:for-each select="descendant::tei:row/tei:cell[5]">
               <xsl:copy-of select="."/>
            </xsl:for-each>
         </row>
      </xsl:variable>
      <xsl:variable name="longest1" as="xs:string?">
         <xsl:call-template name="foo:laengsterTextInSpalte">
            <xsl:with-param name="spalte" select="$spalte1"/>
         </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="longest2" as="xs:string?">
         <xsl:call-template name="foo:laengsterTextInSpalte">
            <xsl:with-param name="spalte" select="$spalte2"/>
         </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="longest3" as="xs:string?">
         <xsl:call-template name="foo:laengsterTextInSpalte">
            <xsl:with-param name="spalte" select="$spalte3"/>
         </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="longest4" as="xs:string?">
         <xsl:call-template name="foo:laengsterTextInSpalte">
            <xsl:with-param name="spalte" select="$spalte4"/>
         </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="longest5" as="xs:string?">
         <xsl:call-template name="foo:laengsterTextInSpalte">
            <xsl:with-param name="spalte" select="$spalte5"/>
         </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="tabellen-anzahl" as="xs:integer"
         select="count(ancestor::tei:body//tei:table)"/>
      <xsl:variable name="xml-id-part" as="xs:string" select="ancestor::tei:TEI/@xml:id"/>
      <xsl:text>\settowidth{\longeste}{</xsl:text>
      <xsl:value-of select="$longest1"/>
      <xsl:text>}</xsl:text>
      <xsl:text>\settowidth{\longestz}{</xsl:text>
      <xsl:value-of select="$longest2"/>
      <xsl:text>}</xsl:text>
      <xsl:text>\settowidth{\longestd}{</xsl:text>
      <xsl:value-of select="$longest3"/>
      <xsl:text>}</xsl:text>
      <xsl:text>\settowidth{\longestv}{</xsl:text>
      <xsl:value-of select="$longest4"/>
      <xsl:text>}</xsl:text>
      <xsl:text>\settowidth{\longestf}{</xsl:text>
      <xsl:value-of select="$longest5"/>
      <xsl:text>}</xsl:text>
      <xsl:choose>
         <xsl:when test="string-length($longest5) &gt; 0">
            <xsl:text>\addtolength\longeste{1em}
        \addtolength\longestz{0.5em}
        \addtolength\longestd{0.5em}
        \addtolength\longestv{0.5em}
        \addtolength\longestf{0.5em}</xsl:text>
         </xsl:when>
         <xsl:when test="string-length($longest4) &gt; 0">
            <xsl:text>\addtolength\longeste{1em}
        \addtolength\longestz{1em}
        \addtolength\longestd{1em}
        \addtolength\longestv{1em}
      </xsl:text>
         </xsl:when>
         <xsl:when test="string-length($longest3) &gt; 0">
            <xsl:text>\addtolength\longeste{1em}
        \addtolength\longestz{1em}
        \addtolength\longestd{1em}
      </xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>\addtolength\longeste{1em}
        \addtolength\longestz{1em}
      </xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:choose>
         <xsl:when test="descendant::tei:row/tei:cell[5]">
            <xsl:text>\textcolor{red}{Tabellen mit mehr als fünf Spalten bislang nicht vorgesehen XXXXX}</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:for-each select="tei:row">
               <xsl:text>\pstart\noindent</xsl:text>
               <xsl:text>\makebox[</xsl:text>
               <xsl:text>\the\longeste</xsl:text>
               <xsl:text>][l]{</xsl:text>
               <xsl:apply-templates select="tei:cell[1]"/>
               <xsl:text>}</xsl:text>
               <xsl:text>\makebox[</xsl:text>
               <xsl:text>\the\longestz</xsl:text>
               <xsl:text>][l]{</xsl:text>
               <xsl:apply-templates select="tei:cell[2]"/>
               <xsl:text>}
                  </xsl:text>
               <xsl:if test="string-length($longest3) &gt; 0">
                  <xsl:text>\makebox[</xsl:text>
                  <xsl:text>\the\longestd</xsl:text>
                  <xsl:text>][l]{</xsl:text>
                  <xsl:apply-templates select="tei:cell[3]"/>
                  <xsl:text>}</xsl:text>
               </xsl:if>
               <xsl:if test="string-length($longest4) &gt; 0">
                  <xsl:text>\makebox[</xsl:text>
                  <xsl:text>\the\longestd</xsl:text>
                  <xsl:text>][l]{</xsl:text>
                  <xsl:apply-templates select="tei:cell[4]"/>
                  <xsl:text>}</xsl:text>
               </xsl:if>
               <xsl:if test="string-length($longest5) &gt; 0">
                  <xsl:text>\makebox[</xsl:text>
                  <xsl:text>\the\longestd</xsl:text>
                  <xsl:text>][l]{</xsl:text>
                  <xsl:apply-templates select="tei:cell[5]"/>
                  <xsl:text>}</xsl:text>
               </xsl:if>
               <xsl:text>\pend</xsl:text>
            </xsl:for-each>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:template match="tei:table[@rend = 'group']">
      <xsl:text>\smallskip\hspace{-5.75em}\begin{tabular}{</xsl:text>
      <xsl:choose>
         <xsl:when test="@cols = 1">
            <xsl:text>l</xsl:text>
         </xsl:when>
         <xsl:when test="@cols = 2">
            <xsl:text>ll</xsl:text>
         </xsl:when>
         <xsl:when test="@cols = 3">
            <xsl:text>lll</xsl:text>
         </xsl:when>
      </xsl:choose>
      <xsl:text>}</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>\end{tabular}</xsl:text>
   </xsl:template>
   <xsl:template match="tei:table[ancestor::tei:table]">
      <xsl:text>\begin{tabular}{</xsl:text>
      <xsl:choose>
         <xsl:when test="@cols = 1">
            <xsl:text>l</xsl:text>
         </xsl:when>
         <xsl:when test="@cols = 2">
            <xsl:text>ll</xsl:text>
         </xsl:when>
         <xsl:when test="@cols = 3">
            <xsl:text>lll</xsl:text>
         </xsl:when>
      </xsl:choose>
      <xsl:text>}</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>\end{tabular}</xsl:text>
   </xsl:template>
   <xsl:template match="tei:row[parent::tei:table[@rend = 'group']]">
      <xsl:choose>
         <!-- Eine Klammer kriegen nur die, die auch mehr als zwei Zeilen haben -->
         <xsl:when test="child::tei:cell/@role = 'label' and child::tei:cell/tei:table/tei:row[2]">
            <xsl:text>$\left.</xsl:text>
            <xsl:apply-templates select="tei:cell[not(@role = 'label')]"/>
            <xsl:text>\right\}$ </xsl:text>
            <xsl:apply-templates select="tei:cell[@role = 'label']"/>
         </xsl:when>
         <xsl:when
            test="child::tei:cell/@role = 'label' and not(child::tei:cell/tei:table/tei:row[2])">
            <xsl:text>$\left.</xsl:text>
            <xsl:apply-templates select="tei:cell[not(@role = 'label')]"/>
            <xsl:text>\right.$\hspace{0.9em}</xsl:text>
            <xsl:apply-templates select="tei:cell[@role = 'label']"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:apply-templates/>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:choose>
         <xsl:when test="position() = last()"/>
         <xsl:otherwise>
            <xsl:text>\\ </xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:template
      match="tei:row[parent::tei:table[not(@rend = 'group')] and ancestor::tei:table[@rend = 'group']]">
      <xsl:apply-templates/>
      <xsl:choose>
         <xsl:when test="position() = last()"/>
         <xsl:otherwise>
            <xsl:text>\\ </xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <!-- Sonderfall anchors, die einen Text umrahmen, damit man auf eine Textstelle verweisen kann -->
   <xsl:template match="tei:anchor[@type = 'label']">
      <xsl:choose>
         <xsl:when test="ends-with(@xml:id, 'v') or ends-with(@xml:id, 'h')">
            <xsl:text>\label{</xsl:text>
            <xsl:value-of select="@xml:id"/>
            <xsl:text>}</xsl:text>
            <xsl:apply-templates/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>\label{</xsl:text>
            <xsl:value-of select="@xml:id"/>
            <xsl:text>v}</xsl:text>
            <xsl:apply-templates/>
            <xsl:text>\label{</xsl:text>
            <xsl:value-of select="@xml:id"/>
            <xsl:text>h}</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <!-- anchors in Fussnoten, sehr seltener Fall-->
   <xsl:template
      match="tei:anchor[(@type = 'textConst' or @type = 'commentary') and ancestor::tei:note[@type = 'footnote']]">
      <xsl:variable name="xmlid" select="@xml:id"/>
      <xsl:variable name="type" select="@type"/>
      <xsl:text>\label{</xsl:text>
      <xsl:value-of select="@xml:id"/>
      <xsl:text>v}</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>\toendnotes[C]{\begin{minipage}[t]{4em}{\makebox[3.6em][r]{\tiny{Fußnote}}}\end{minipage}\begin{minipage}[t]{\dimexpr\linewidth-4em}\textit{</xsl:text>
      <xsl:for-each-group select="following-sibling::node()"
         group-ending-with="tei:note[@type = $type]">
         <xsl:if test="position() eq 1">
            <xsl:apply-templates select="current-group()[position() != last()]" mode="lemma"/>
            <xsl:text>}\,{]} </xsl:text>
            <xsl:apply-templates select="current-group()[position() = last()]" mode="text"/>
            <xsl:text>\end{minipage}\par}</xsl:text>
         </xsl:if>
      </xsl:for-each-group>
   </xsl:template>
   <!-- Normaler anchor, Inhalt leer -->
   <xsl:template
      match="tei:anchor[(@type = 'textConst' or @type = 'commentary') and not(ancestor::tei:note[@type = 'footnote'])]">
      <xsl:variable name="typ-i-typ" select="@type"/>
      <xsl:variable name="id" select="@xml:id"/>
      <xsl:variable name="lemmatext" as="xs:string">
         <xsl:for-each-group select="following-sibling::node()"
            group-ending-with="tei:note[@type = $typ-i-typ and @corresp = $id][1]">
            <xsl:if test="position() eq 1">
               <xsl:apply-templates select="current-group()[position() != last()]" mode="lemma"/>
            </xsl:if>
         </xsl:for-each-group>
      </xsl:variable>
      <xsl:text>\label{</xsl:text>
      <xsl:value-of select="@xml:id"/>
      <xsl:text>v}</xsl:text>
      <xsl:text>\edtext{</xsl:text>
      <xsl:apply-templates/>
   </xsl:template>
   <xsl:template
      match="tei:note[(@type = 'textConst' or @type = 'commentary') and not(ancestor::tei:note[@type = 'footnote'])]"
      mode="lemma"/>
   <xsl:template match="tei:space[@unit = 'chars' and @quantity = '1']" mode="lemma">
      <xsl:text> </xsl:text>
   </xsl:template>
   <xsl:template
      match="tei:note[(@type = 'textConst' or @type = 'commentary') and not(ancestor::tei:note[@type = 'footnote'])]">
      <xsl:text>}{</xsl:text>
      <!-- Der Teil hier bildet das Lemma und kürzt es -->
      <xsl:variable name="corresp" as="xs:string" select="@corresp"/>
      <xsl:variable name="lemmaganz">
         <xsl:for-each-group
            select="preceding-sibling::tei:anchor[@xml:id = $corresp]/following-sibling::node()"
            group-ending-with="tei:note[@corresp = $corresp]">
            <xsl:if test="position() eq 1">
               <xsl:apply-templates select="current-group()[position() != last()]" mode="lemma"/>
            </xsl:if>
         </xsl:for-each-group>
      </xsl:variable>
      <xsl:variable name="lemma" as="xs:string">
         <xsl:choose>
            <xsl:when test="not(contains($lemmaganz, ' '))">
               <xsl:value-of select="$lemmaganz"/>
            </xsl:when>
            <xsl:when test="string-length(normalize-space($lemmaganz)) &gt; 24">
               <xsl:variable name="lemma-kurz"
                  select="concat(tokenize(normalize-space($lemmaganz), ' ')[1], ' … ', tokenize(normalize-space($lemmaganz), ' ')[last()])"/>
               <xsl:choose>
                  <xsl:when
                     test="string-length(normalize-space($lemmaganz)) - string-length($lemma-kurz) &lt; 5">
                     <xsl:value-of select="normalize-space($lemmaganz)"/>
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:value-of select="$lemma-kurz"/>
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="$lemmaganz"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:text>\lemma{\textnormal{\emph{</xsl:text>
      <xsl:choose>
         <xsl:when test="*:Lemma">
            <xsl:apply-templates select="*:Lemma" mode="lemma"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:choose>
               <xsl:when test="string-length($lemma) &gt; 0">
                  <xsl:value-of select="$lemma"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:text>XXXX Lemmafehler</xsl:text>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:text>}}}</xsl:text>
      <xsl:choose>
         <xsl:when test="@type = 'textConst'">
            <!-- 
            möchte man textConst abgespalten, dann <xsl:text>\Aendnote{\textnormal{</xsl:text>
            
            -->
            <xsl:text>\Cendnote{\textnormal{</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>\Cendnote{\textnormal{</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="node() except Lemma"/>
      <xsl:text>}}}</xsl:text>
      <xsl:text>\label{</xsl:text>
      <xsl:value-of select="@corresp"/>
      <xsl:text>}</xsl:text>
   </xsl:template>
   <xsl:template match="tei:del" mode="lemma"/>
   <xsl:template match="tei:subst/tei:del" mode="lemma"/>
   <!-- das verhindert die Wiedergabe des gelöschten Teils von subst in einem Lemma -->
   <xsl:template
      match="tei:note[(@type = 'textConst' or @type = 'commentary') and (ancestor::tei:note[@type = 'footnote'])]">
      <!--     <xsl:text>\toendnotes[C]{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>\par}</xsl:text>-->
      <xsl:text>\label{1</xsl:text>
      <xsl:value-of select="@xml:id"/>
      <xsl:text>}</xsl:text>
   </xsl:template>
   <xsl:template match="tei:ptr">
      <xsl:text>XXXXXXXXXX</xsl:text>
      <xsl:if test="not(@arrow = 'no')">
         <xsl:text>$\triangleright$</xsl:text>
      </xsl:if>
      <xsl:text>\myrangeref{</xsl:text>
      <xsl:value-of select="@target"/>
      <xsl:text>v}{</xsl:text>
      <xsl:value-of select="@target"/>
      <xsl:text>h}</xsl:text>
   </xsl:template>
   <xsl:template match="tei:cell[parent::tei:row[parent::tei:table[@rend = 'group']]]">
      <xsl:apply-templates/>
      <xsl:if test="following-sibling::cell">
         <xsl:text> </xsl:text>
      </xsl:if>
   </xsl:template>
   <xsl:template
      match="tei:cell[parent::tei:row[parent::tei:table[not(@rend = 'group')]] and ancestor::tei:table[@rend = 'group']]">
      <xsl:choose>
         <xsl:when test="position() = 1">
            <xsl:text>\makebox[0.2\textwidth][r]{</xsl:text>
            <xsl:apply-templates/>
            <xsl:text>}</xsl:text>
         </xsl:when>
         <xsl:when test="position() = 2">
            <xsl:text>\makebox[0.5\textwidth][l]{</xsl:text>
            <xsl:apply-templates/>
            <xsl:text>}</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:apply-templates/>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="following-sibling::tei:cell">
         <xsl:text>\newcell </xsl:text>
      </xsl:if>
   </xsl:template>
   <xsl:template match="tei:opener">
      <xsl:apply-templates/>
      <xsl:text>\vspace{0.5em}</xsl:text>
   </xsl:template>
   <xsl:template match="tei:encodingDesc/tei:refsDecl/tei:ab"/>
   <!-- Titel -->
   <xsl:template match="tei:head">
      <xsl:choose>
         <xsl:when test="not(preceding-sibling::*)">
            <xsl:text>\nopagebreak[4] </xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>\pagebreak[2] </xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:choose>
         <xsl:when
            test="not(position() = 1) and not(preceding-sibling::*[1][self::tei:head]) and @type = 'sub'">
            <!-- Es befindet sich im Text und direkt davor steht nicht schon ein head -->
            <xsl:text>&#10;{\centering\pstart[\vspace{0.35\baselineskip}]\noindent\leftskip=3em plus1fill\rightskip\leftskip
            </xsl:text>
         </xsl:when>
         <xsl:when test="not(position() = 1) and not(preceding-sibling::*[1][self::tei:head])">
            <!-- Es befindet sich im Text und direkt davor steht nicht schon ein head -->
            <xsl:text>&#10;{\centering\pstart[\vspace{1\baselineskip}]\noindent\leftskip=3em plus1fill\rightskip\leftskip
            </xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <!-- kein Abstand davor wenn es das erste Element-->
            <xsl:text>&#10;{\centering\pstart\noindent\leftskip=3em plus1fill\rightskip\leftskip
            </xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="not(@type = 'sub')">
         <xsl:text/>
         <xsl:text>\textbf{</xsl:text>
      </xsl:if>
      <xsl:apply-templates/>
      <xsl:if test="not(@type = 'sub')">
         <xsl:text>}</xsl:text>
      </xsl:if>
      <xsl:choose>
         <xsl:when test="not(following-sibling::*[1][self::tei:head]) and @type = 'sub'">
            <xsl:text>&#10;\pend[\vspace{0.15\baselineskip}]}</xsl:text>
         </xsl:when>
         <xsl:when test="not(following-sibling::*[1][self::tei:head])">
            <xsl:text>&#10;\pend[\vspace{0.5\baselineskip}]}</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>&#10;\pend}
            </xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:text>&#10;\nopagebreak[4] </xsl:text>
   </xsl:template>
   <xsl:template match="tei:head[ancestor::tei:TEI[starts-with(@xml:id, 'E')]]">
      <xsl:choose>
         <xsl:when test="@sub">
            <xsl:text>&#10;\subsection{</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>&#10;\addsec*{</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates/>
      <xsl:text>}\noindent{}</xsl:text>
   </xsl:template>
   <xsl:template
      match="tei:div[(@type = 'writingSession') and not(ancestor::*[self::tei:text[@type = 'dedication']])]">
      <xsl:variable name="language"
         select="substring(ancestor::tei:TEI//tei:profileDesc/tei:langUsage/tei:language/@xml:ident, 1, 2)"/>
      <xsl:choose>
         <xsl:when test="@xml:lang = 'de-AT'"/>
         <xsl:when test="$language = 'en'">
            <xsl:text>\selectlanguage{english}\frenchspacing </xsl:text>
         </xsl:when>
         <xsl:when test="$language = 'fr'">
            <xsl:text>\selectlanguage{french}</xsl:text>
         </xsl:when>
         <xsl:when test="$language = 'it'">
            <xsl:text>\selectlanguage{italian}</xsl:text>
         </xsl:when>
         <xsl:when test="$language = 'hu'">
            <xsl:text>\selectlanguage{magyar}</xsl:text>
         </xsl:when>
         <xsl:when test="$language = 'dk'">
            <xsl:text>\selectlanguage{danish}</xsl:text>
         </xsl:when>
         <xsl:when test="$language = 'jp'">
            <xsl:text>\selectlanguage{japanese}</xsl:text>
         </xsl:when>
      </xsl:choose>
      <xsl:if test="preceding-sibling::tei:*[1]/name()[. = 'div']">
         <xsl:text>\vspace{1em}</xsl:text>
      </xsl:if>
      <xsl:apply-templates/>
      <xsl:if test="not($language = 'de') or @xml:lang = 'de-AT'">
         <xsl:text>\selectlanguage{ngerman}</xsl:text>
      </xsl:if>
   </xsl:template>
   <xsl:template
      match="tei:div[@type = 'writingSession' and ancestor::*[self::tei:text[@type = 'dedication']]]">
      <xsl:text>\centerline{\begin{minipage}{0.5\textwidth}</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>\end{minipage}}</xsl:text>
   </xsl:template>
   <xsl:template match="tei:div[@type = 'image']">
      <xsl:apply-templates/>
   </xsl:template>
   <xsl:template match="tei:address">
      <xsl:apply-templates/>
      <xsl:text>{\bigskip}</xsl:text>
   </xsl:template>
   <xsl:template match="tei:addrLine">
      <xsl:text>\pstart{}</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>\pend{}</xsl:text>
   </xsl:template>
   <xsl:template match="tei:postscript">
      <!--<xsl:text>\noindent{}</xsl:text>-->
      <xsl:apply-templates/>
   </xsl:template>
   <xsl:template match="tei:quote">
      <xsl:choose>
         <xsl:when
            test="ancestor::tei:physDesc | ancestor::tei:note[@type = 'commentary'] | ancestor::tei:note[@type = 'textConst'] | ancestor::tei:div[@type = 'biographical']">
            <xsl:apply-templates/>
         </xsl:when>
         <xsl:when test="ancestor::tei:TEI[substring(@xml:id, 1, 1) = 'E']">
            <xsl:choose>
               <xsl:when test="substring(current(), 1, 1) = '»'">
                  <xsl:text>\begin{quoting}\noindent{}</xsl:text>
                  <xsl:apply-templates/>
                  <xsl:text>\end{quoting}</xsl:text>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:apply-templates/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>\begin{quotation}\noindent{}</xsl:text>
            <xsl:apply-templates/>
            <xsl:text>\end{quotation}</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:template match="tei:lg[@type = 'poem']">
      <xsl:choose>
         <xsl:when test="child::tei:lg[@type = 'stanza']">
            <xsl:apply-templates/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>\stanza{}</xsl:text>
            <xsl:apply-templates/>
            <xsl:text>\stanzaend{}</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:template match="tei:lg[@type = 'stanza']">
      <xsl:text>\stanza{}</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>\stanzaend{}</xsl:text>
   </xsl:template>
   <xsl:template match="tei:l[ancestor::tei:lg[@type = 'stanza' or @type = 'poem']]">
      <xsl:if test="@rend = 'inline'">
         <xsl:text>\stanzaindent{2}</xsl:text>
      </xsl:if>
      <xsl:if test="@rend = 'center'">
         <xsl:text>\centering{}</xsl:text>
      </xsl:if>
      <xsl:apply-templates/>
      <xsl:if test="following-sibling::l">
         <xsl:text>\newverse{}</xsl:text>
      </xsl:if>
   </xsl:template>
   <!-- Pagebreaks -->
   <xsl:template match="tei:pb">
      <xsl:text>{\pb}</xsl:text>
   </xsl:template>
   <!-- Kaufmanns-Und & -->
   <xsl:template match="tei:c[@rendition = '#kaufmannsund']">
      <xsl:text>{\kaufmannsund}</xsl:text>
   </xsl:template>
   <xsl:template match="tei:c[@rendition = '#tilde']">
      <xsl:text>{\char`~}</xsl:text>
   </xsl:template>
   <xsl:template match="tei:c[@rendition = '#geschwungene-klammer-auf']">
      <xsl:text>{\{}</xsl:text>
   </xsl:template>
   <xsl:template match="tei:c[@rendition = '#geschwungene-klammer-zu']">
      <xsl:text>{\}}</xsl:text>
   </xsl:template>
   <!-- Geminationsstriche -->
   <xsl:template match="tei:c[@rendition = '#gemination-m']">
      <xsl:text>{\geminationm}</xsl:text>
   </xsl:template>
   <xsl:template match="tei:c[@rendition = '#langesS']">
      <xsl:text>ſ</xsl:text>
   </xsl:template>
   <xsl:template match="tei:c[@rendition = '#gemination-n']">
      <xsl:text>{\geminationn}</xsl:text>
   </xsl:template>
   <xsl:template match="tei:c[@rendition = '#gemination-m']" mode="lemma">
      <xsl:text>mm</xsl:text>
   </xsl:template>
   <xsl:template match="tei:c[@rendition = '#gemination-n']" mode="lemma">
      <xsl:text>nn</xsl:text>
   </xsl:template>
   <!-- Prozentzeichen % -->
   <xsl:template match="tei:c[@rendition = '#prozent']">
      <xsl:text>{\%}</xsl:text>
   </xsl:template>
   <!-- Dollarzeichen $ -->
   <xsl:template match="tei:c[@rendition = '#dollar']">
      <xsl:text>{\$}</xsl:text>
   </xsl:template>
   <!-- Unterstreichung -->
   <xsl:template match="tei:hi[@rend = 'underline']">
      <xsl:choose>
         <xsl:when
            test="parent::tei:hi[@rend = 'superscript'] | parent::tei:hi[parent::tei:signed and @rend = 'overline'] | ancestor::tei:addrLine">
            <xsl:apply-templates/>
         </xsl:when>
         <xsl:when test="not(@n)">
            <xsl:text>\textcolor{red}{UNTERSTREICHUNG FEHLER:</xsl:text>
            <xsl:apply-templates/>
            <xsl:text>}</xsl:text>
         </xsl:when>
         <xsl:when test="@hand">
            <xsl:text>\uline{</xsl:text>
            <xsl:apply-templates/>
            <xsl:text>}</xsl:text>
         </xsl:when>
         <xsl:when test="@n = '1'">
            <xsl:text>\uline{</xsl:text>
            <xsl:apply-templates/>
            <xsl:text>}</xsl:text>
         </xsl:when>
         <xsl:when test="@n = '2'">
            <xsl:text>\uuline{</xsl:text>
            <xsl:apply-templates/>
            <xsl:text>}</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>\uuline{\edtext{</xsl:text>
            <xsl:apply-templates/>
            <xsl:text>}{</xsl:text>
            <xsl:if test="@n &gt; 2">
               <xsl:text>\Cendnote{</xsl:text>
               <xsl:choose>
                  <xsl:when test="@n = 3">
                     <xsl:text>drei</xsl:text>
                  </xsl:when>
                  <xsl:when test="@n = 4">
                     <xsl:text>vier</xsl:text>
                  </xsl:when>
                  <xsl:when test="@n = 5">
                     <xsl:text>fünf</xsl:text>
                  </xsl:when>
                  <xsl:when test="@n = 6">
                     <xsl:text>sechs</xsl:text>
                  </xsl:when>
                  <xsl:when test="@n = 7">
                     <xsl:text>sieben</xsl:text>
                  </xsl:when>
                  <xsl:when test="@n = 8">
                     <xsl:text>acht</xsl:text>
                  </xsl:when>
                  <xsl:when test="@n &gt; 8">
                     <xsl:text>unendlich viele Quatrillionentrilliarden und noch viel mehrmal unterstrichen</xsl:text>
                  </xsl:when>
               </xsl:choose>
               <xsl:text>fach unterstrichen</xsl:text>
               <xsl:text>}}}</xsl:text>
            </xsl:if>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:template match="tei:hi[@rend = 'overline']">
      <xsl:choose>
         <xsl:when test="parent::tei:signed | ancestor::tei:addressLine">
            <xsl:apply-templates/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>\textoverline{</xsl:text>
            <xsl:apply-templates/>
            <xsl:text>}</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <!-- Herausgebereingriff -->
   <xsl:template match="tei:supplied[not(parent::tei:damage)]">
      <xsl:text disable-output-escaping="yes">{[}</xsl:text>
      <xsl:apply-templates/>
      <xsl:text disable-output-escaping="yes">{]}</xsl:text>
   </xsl:template>
   <!-- Unleserlich, unsicher Entziffertes -->
   <xsl:template match="tei:unclear">
      <xsl:text>\textcolor{gray}{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
   </xsl:template>
   <!-- Durch Zerstörung unleserlich. Text ist stets Herausgebereingriff -->
   <xsl:template match="tei:damage">
      <xsl:text>\damage{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
   </xsl:template>
   <!-- Loch / Unentziffertes -->
   <xsl:function name="foo:gapigap">
      <xsl:param name="gapchars" as="xs:integer"/>
      <xsl:text>\textcolor{gray}{×}</xsl:text>
      <xsl:if test="$gapchars &gt; 1">
         <xsl:text>\-</xsl:text>
         <xsl:value-of select="foo:gapigap($gapchars - 1)"/>
      </xsl:if>
   </xsl:function>
   <xsl:template match="tei:gap[@unit = 'chars' and (@reason = 'illegible' or @reason = 'textualLoss')]">
      <xsl:value-of select="foo:gapigap(@quantity)"/>
   </xsl:template>
   <xsl:template match="tei:gap[@unit = 'lines' and @reason = 'illegible']">
      <xsl:text>\textcolor{gray}{[</xsl:text>
      <xsl:choose>
         <xsl:when test="@quantity = 1">
            <xsl:text>unleserliche Zeile</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="@quantity"/>
            <xsl:text> Zeilen unleserlich</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:text>{]} }</xsl:text>
   </xsl:template>
   <xsl:template match="tei:gap[@unit = 'lines' and @reason = 'textualLoss']">
      <xsl:text>\textcolor{gray}{[</xsl:text>
      <xsl:choose>
         <xsl:when test="@quantity = 1">
            <xsl:text>eine Zeile Textverlust</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="@quantity"/>
            <xsl:text> Zeilen Textverlust</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:text>{]} }</xsl:text>
   </xsl:template>
   <xsl:template match="tei:gap[@reason = 'outOfScope']">
      <xsl:text>{[}\ldots{]}</xsl:text>
   </xsl:template>
   <xsl:template match="tei:gap[@reason = 'gabelsberger']">
      <xsl:text>\textcolor{BurntOrange}{[Gabelsberger]}</xsl:text>
   </xsl:template>
   <xsl:function name="foo:punkte">
      <xsl:param name="nona" as="xs:integer"/>
      <xsl:text>.</xsl:text>
      <xsl:if test="$nona - 1 &gt; 0">
         <xsl:value-of select="foo:punkte($nona - 1)"/>
      </xsl:if>
   </xsl:function>
   <!-- Auslassungszeichen, drei Punkte, mehr Punkte -->
   <xsl:template match="tei:c[@rendition = '#dots']">
      <!-- <xsl:choose>-->
      <!-- <xsl:when test="@place='center'">-->
      <xsl:choose>
         <xsl:when test="@n = '3'">
            <xsl:text>{\dots}</xsl:text>
         </xsl:when>
         <xsl:when test="@n = '4'">
            <xsl:text>{\dotsfour}</xsl:text>
         </xsl:when>
         <xsl:when test="@n = '5'">
            <xsl:text>{\dotsfive}</xsl:text>
         </xsl:when>
         <xsl:when test="@n = '6'">
            <xsl:text>{\dotssix}</xsl:text>
         </xsl:when>
         <xsl:when test="@n = '7'">
            <xsl:text>{\dotsseven}</xsl:text>
         </xsl:when>
         <xsl:when test="@n = '2'">
            <xsl:text>{\dotstwo}</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="foo:punkte(@n)"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--</xsl:when>-->
      <!--<xsl:otherwise>
            <xsl:choose>
               <xsl:when test="@n='3'">
                  <xsl:text>\dots </xsl:text>
               </xsl:when>
               <xsl:when test="@n='4'">
                  <xsl:text>\dotsfour </xsl:text>
               </xsl:when>
               <xsl:when test="@n='5'">
                  <xsl:text>\dotsfive </xsl:text>
               </xsl:when>
               <xsl:when test="@n='6'">
                  <xsl:text>\dotssix </xsl:text>
               </xsl:when>
               <xsl:when test="@n='7'">
                  <xsl:text>\dotsseven </xsl:text>
               </xsl:when>
               <xsl:when test="@n='2'">
                  <xsl:text>\dotstwo </xsl:text>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:text>\textcolor{red}{XXXX Punkte Fehler!!!}</xsl:text>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:otherwise>
      </xsl:choose>-->
   </xsl:template>
   <xsl:template match="tei:p[child::tei:space[@dim] and not(child::tei:*[2]) and empty(text())]">
      <xsl:text>{\bigskip}</xsl:text>
   </xsl:template>
   <xsl:template match="tei:space[@dim = 'vertical']">
      <xsl:text>{\vspace{</xsl:text>
      <xsl:value-of select="@quantity"/>
      <xsl:text>\baselineskip}}</xsl:text>
   </xsl:template>
   <xsl:template match="tei:space[@unit = 'chars']">
      <xsl:choose>
         <xsl:when test="@style = 'hfill' and not(following-sibling::node()[1][self::tei:signed])"/>
         <xsl:when
            test="@quantity = 1 and not(string-length(normalize-space(parent::tei:p)) = 0 and parent::tei:p[child::tei:*[1] = space[@unit = 'chars' and @quantity = '1']] and parent::tei:p[not(child::tei:*[2])])">
            <xsl:text>{ }</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>\hspace*{</xsl:text>
            <xsl:value-of select="0.5 * @quantity"/>
            <xsl:text>em}</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:template match="tei:signed">
      <xsl:text>\spacefill</xsl:text>
      <xsl:text>\mbox{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
   </xsl:template>
   <!-- Hinzufügung im Text -->
   <xsl:template match="tei:add[@place and not(parent::tei:subst)]">
      <xsl:text>\introOben{}</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>\introOben{}</xsl:text>
   </xsl:template>
   <!-- Streichung -->
   <xsl:template match="tei:del[not(parent::tei:subst)]">
      <xsl:text>\strikeout{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
   </xsl:template>
   <xsl:template match="tei:del[parent::tei:subst]">
      <xsl:apply-templates/>
   </xsl:template>
   <xsl:template match="tei:hyphenation">
      <xsl:choose>
         <xsl:when test="@alt">
            <xsl:value-of select="@alt"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:apply-templates/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <!-- Substi -->
   <xsl:template match="tei:subst">
      <xsl:text>\substVorne{}\textsuperscript{</xsl:text>
      <xsl:apply-templates select="tei:del"/>
      <xsl:text>}</xsl:text>
      <xsl:if test="string-length(del) &gt; 5">
         <xsl:text>{\allowbreak}</xsl:text>
      </xsl:if>
      <xsl:text>\substDazwischen{}</xsl:text>
      <xsl:apply-templates select="tei:add"/>
      <xsl:text>\substHinten{}</xsl:text>
   </xsl:template>
   <!-- Wechsel der Schreiber <handShift -->
   <xsl:template match="tei:handShift[not(@scribe)]">
      <xsl:choose>
         <xsl:when test="@medium = 'typewriter'">
            <xsl:text>{[}ms.:{]} </xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>{[}hs.:{]} </xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:template match="tei:handShift[@scribe]">
      <xsl:variable name="scribe" select="replace(@scribe, '#', '')"/>
      <xsl:variable name="scribe-vorname"
         select="ancestor::tei:TEI/tei:text/tei:back/tei:listPerson/tei:person[@xml:id = $scribe]/tei:persName[1]/tei:forename[1]"/>
      <xsl:variable name="scribe-nachname"
         select="ancestor::tei:TEI/tei:text/tei:back/tei:listPerson/tei:person[@xml:id = $scribe]/tei:persName[1]/tei:surname[1]"/>
      <xsl:variable name="scribes" as="node()">
         <xsl:element name="scribes">
            <xsl:for-each
               select="ancestor::tei:TEI/descendant::tei:handNote/@corresp[not(. = 'schreibkraft')]">
               <xsl:element name="scribe">
                  <xsl:attribute name="id">
                     <xsl:value-of select="replace(., '#', '')"/>
                  </xsl:attribute>
               </xsl:element>
            </xsl:for-each>
            <xsl:for-each select="ancestor::tei:TEI/descendant::tei:handShift/@scribe">
               <!-- das ist ein Sonderfall, dass ein Zettel einer fremden Handschrift eingeklebt ist – oder
         eine Beilage -->
               <xsl:element name="scribe">
                  <xsl:attribute name="id">
                     <xsl:value-of select="replace(., '#', '')"/>
                  </xsl:attribute>
               </xsl:element>
            </xsl:for-each>
         </xsl:element>
      </xsl:variable>
      <xsl:variable name="scribes-namen" as="node()">
         <!-- alle Namen, außer dem aktuellen -->
         <xsl:element name="listPerson">
            <xsl:for-each
               select="ancestor::tei:TEI/tei:text/tei:back/tei:listPerson/tei:person[@xml:id = $scribes/tei:scribe/@xml:id and not(@xml:id = $scribe)]">
               <xsl:element name="person">
                  <xsl:attribute name="id">
                     <xsl:value-of select="@xml:id"/>
                  </xsl:attribute>
                  <xsl:copy-of select="tei:persName[1]"/>
               </xsl:element>
            </xsl:for-each>
         </xsl:element>
      </xsl:variable>
      <xsl:text>{[}hs. </xsl:text>
      <xsl:choose>
         <xsl:when
            test="$scribes-namen[descendant::tei:persName[tei:surname = $scribe-nachname and tei:forename = $scribe-vorname]][1]">
            <!-- es gibt zwei namensgleiche Schreiber, wie bei Hofmannsthal junior und senior, aber
         momentan kommts nicht vor, drum zeigt er nur eine Fehlermeldung-->
            <xsl:value-of select="fn:concat($scribe-vorname, ' ', $scribe-nachname)"/>
            <xsl:text>XXXX Namendopplung</xsl:text>
         </xsl:when>
         <xsl:when test="$scribes-namen[descendant::tei:surname = $scribe-nachname][1]">
            <!-- es gibt mindestens einen anderen Schreiber mit dem gleichen Nachnamen -->
            <xsl:value-of select="fn:concat($scribe-vorname, ' ', $scribe-nachname)"/>
         </xsl:when>
         <!-- hier könnte man noch Verwendung von Initialen einbauen -->
         <xsl:otherwise>
            <xsl:value-of select="$scribe-nachname"/>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:text>:{]} </xsl:text>
      <!--  <xsl:if test="ancestor::tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author/@ref != @scribe">
      <xsl:value-of select="foo:person-in-index(@scribe,true())"/>
      <xsl:text>}</xsl:text>
      </xsl:if>-->
   </xsl:template>
   <!-- Kursiver Text für Schriftwechsel in den Handschriften-->
   <xsl:template match="tei:hi[@rend = 'latintype']">
      <xsl:choose>
         <xsl:when test="ancestor::tei:signed">
            <xsl:apply-templates/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>\textsc{</xsl:text>
            <xsl:apply-templates/>
            <xsl:text>}</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <!-- Fett und grau für Vorgedrucktes-->
   <xsl:template match="tei:hi[@rend = 'pre-print']">
      <xsl:text>\textcolor{gray}{</xsl:text>
      <xsl:text>\textbf{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}}</xsl:text>
   </xsl:template>
   <!-- Fett, grau und kursiv für Stempel-->
   <xsl:template match="tei:hi[@rend = 'stamp']">
      <xsl:text>\textcolor{gray}{</xsl:text>
      <xsl:text>\textbf{\textit{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}}}</xsl:text>
   </xsl:template>
   <!-- Gabelsberger, wird derzeit Orange ausgewiesen -->
   <xsl:template match="tei:hi[@rend = 'gabelsberger']">
      <xsl:apply-templates/>
   </xsl:template>
   <!-- Kursiver Text für Schriftwechsel im gedruckten Text-->
   <xsl:template match="tei:hi[@rend = 'antiqua']">
      <xsl:text>\textsc{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
   </xsl:template>
   <!-- Kursiver Text -->
   <xsl:template match="tei:hi[@rend = 'italics']">
      <xsl:text>\emph{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
   </xsl:template>
   <!-- Fetter Text -->
   <xsl:template match="tei:hi[@rend = 'bold']">
      <xsl:choose>
         <xsl:when test="ancestor::tei:head | parent::tei:signed">
            <xsl:apply-templates/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>\textbf{</xsl:text>
            <xsl:apply-templates/>
            <xsl:text>}</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <!-- Kapitälchen -->
   <xsl:template match="tei:hi[@rend = 'small-caps']">
      <xsl:text>\textsc{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
   </xsl:template>
   <!-- Großbuchstaben -->
   <xsl:template
      match="tei:hi[@rend = 'capitals' and not(descendant::tei:note) and not(descendant::tei:note[@type = 'footnote'])]//text()">
      <xsl:value-of select="upper-case(.)"/>
   </xsl:template>
   <xsl:template
      match="tei:hi[(@rend = 'capitals' and descendant::tei:note) or (@rend = 'capitals' and descendant::tei:note[@type = 'footnote'])]//text()">
      <xsl:choose>
         <xsl:when
            test="ancestor-or-self::tei:note[@type = 'footnote' and not(descendant::tei:hi[@rend = 'capitals'])] | ancestor-or-self::tei:note[not(descendant::tei:hi[@rend = 'capitals'])]">
            <xsl:value-of select="."/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="upper-case(.)"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <!-- Gesperrter Text -->
   <xsl:template match="tei:hi[@rend = 'spaced-out' and not(child::tei:hi)]">
      <xsl:choose>
         <xsl:when
            test="not(child::tei:*[1]) and ancestor::tei:hi[@rend = 'capitals' and not(descendant::tei:note)]">
            <xsl:text>\so{</xsl:text>
            <xsl:choose>
               <xsl:when test="starts-with(text(), ' ')">
                  <xsl:text> </xsl:text>
                  <xsl:value-of select="upper-case(normalize-space(text()))"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="upper-case(normalize-space(text()))"/>
               </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="ends-with(text(), ' ')">
               <xsl:text> </xsl:text>
            </xsl:if>
            <xsl:text>}</xsl:text>
         </xsl:when>
         <xsl:when test="not(child::tei:*[1])">
            <xsl:text>\so{</xsl:text>
            <xsl:choose>
               <xsl:when test="starts-with(text(), ' ')">
                  <xsl:text> </xsl:text>
                  <xsl:value-of select="normalize-space(text())"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="normalize-space(text())"/>
               </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="ends-with(text(), ' ')">
               <xsl:text> </xsl:text>
            </xsl:if>
            <xsl:text>}</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>\so{</xsl:text>
            <xsl:apply-templates/>
            <xsl:text>}</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <!-- Hochstellung -->
   <xsl:template match="tei:hi[@rend = 'superscript']">
      <xsl:text>\textsuperscript{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
   </xsl:template>
   <xsl:template match="tei:hi[@rend = 'superscript']" mode="lemma">
      <xsl:text>\textsuperscript{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
   </xsl:template>
   <!-- Tiefstellung -->
   <xsl:template match="tei:hi[@rend = 'subscript']">
      <xsl:text>\textsubscript{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
   </xsl:template>
   <xsl:template match="tei:hi[@rend = 'subscript']" mode="lemma">
      <xsl:text>\textsubscript{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
   </xsl:template>
   <xsl:template match="tei:note[@type = 'introduction']">
      <xsl:text>[</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>] </xsl:text>
   </xsl:template>
   <!-- Dieses Template bereitet den Schriftwechsel für griechische Zeichen vor -->
   <xsl:template match="tei:foreign[starts-with(@lang, 'el') or starts-with(@xml:lang, 'el')]">
      <xsl:text>\griechisch{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
   </xsl:template>
   <xsl:template match="tei:foreign[starts-with(@lang, 'he') or starts-with(@xml:lang, 'he')]">
      <xsl:text>\hebraeisch{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
   </xsl:template>
   <xsl:template match="tei:foreign[starts-with(@lang, 'en') or starts-with(@xml:lang, 'en')]">
      <xsl:text>\begin{otherlanguage}{english}</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>\end{otherlanguage}</xsl:text>
   </xsl:template>
   <xsl:template match="tei:foreign[starts-with(@lang, 'fr') or starts-with(@xml:lang, 'fr')]">
      <xsl:text>\begin{otherlanguage}{french}</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>\end{otherlanguage}</xsl:text>
   </xsl:template>
   <xsl:template match="tei:foreign[starts-with(@lang, 'ru') or starts-with(@xml:lang, 'ru')]">
      <xsl:text>\begin{otherlanguage}{russian}\cyrillic{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}\end{otherlanguage}</xsl:text>
   </xsl:template>
   <xsl:template match="tei:foreign[starts-with(@lang, 'hu') or starts-with(@xml:lang, 'hu')]">
      <xsl:text>\begin{otherlanguage}{magyar}</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>\end{otherlanguage}</xsl:text>
   </xsl:template>
   <xsl:template match="tei:foreign[starts-with(@xml:lang, 'dk') or starts-with(@lang, 'dk')]">
      <xsl:text>\begin{otherlanguage}{dansk}</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>\end{otherlanguage}</xsl:text>
   </xsl:template>
   <xsl:template match="tei:foreign[starts-with(@xml:lang, 'nl') or starts-with(@lang, 'nl')]">
      <xsl:text>\begin{otherlanguage}{dutch}</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>\end{otherlanguage}</xsl:text>
   </xsl:template>
   <xsl:template match="tei:foreign[starts-with(@xml:lang, 'sv') or starts-with(@lang, 'sv')]">
      <xsl:text>\begin{otherlanguage}{swedish}</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>\end{otherlanguage}</xsl:text>
   </xsl:template>
   <xsl:template match="tei:foreign[starts-with(@xml:lang, 'it') or starts-with(@lang, 'it')]">
      <xsl:text>\begin{otherlanguage}{italian}</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>\end{otherlanguage}</xsl:text>
   </xsl:template>
   <xsl:template match="tei:foreign[starts-with(@lang, 'ja') or starts-with(@xml:lang, 'ja')]">
      <xsl:text>\japanese{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
   </xsl:template>
   <!-- Templates für Lemma-Modus -->
   <xsl:template match="*" mode="lemma">
      <xsl:apply-templates mode="lemma"/>
   </xsl:template>
   <xsl:template match="text()" mode="lemma">
      <xsl:value-of select="."/>
   </xsl:template>
   <xsl:template match="tei:foreign[starts-with(@lang, 'el') or starts-with(@xml:lang, 'el')]" mode="lemma">
      <xsl:text>\griechisch{</xsl:text>
      <xsl:apply-templates mode="lemma"/>
      <xsl:text>}</xsl:text>
   </xsl:template>
   <xsl:template match="tei:foreign[starts-with(@lang, 'he') or starts-with(@xml:lang, 'he')]" mode="lemma">
      <xsl:text>\hebraeisch{</xsl:text>
      <xsl:apply-templates mode="lemma"/>
      <xsl:text>}</xsl:text>
   </xsl:template>
   <xsl:template match="tei:foreign[starts-with(@lang, 'ja') or starts-with(@xml:lang, 'ja')]" mode="lemma">
      <xsl:text>\japanese{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
   </xsl:template>
   <!-- Ab hier PERSONENINDEX, WERKINDEX UND ORTSINDEX -->
   <!-- Diese Funktion setzt die Fußnoten und Indexeinträge der Personen, wobei übergeben wird, ob man sich gerade im 
  Fließtext oder in Paratexten befindet und ob die Person namentlich genannt oder nur auf sie verwiesen wird -->
   <!-- Diese Funktion setzt das lemma -->
   <xsl:function name="foo:lemma">
      <xsl:param name="lemmatext" as="xs:string"/>
      <xsl:text>\lemma{</xsl:text>
      <xsl:choose>
         <xsl:when
            test="string-length(normalize-space($lemmatext)) gt 30 and count(tokenize($lemmatext, ' ')) gt 5">
            <xsl:value-of select="tokenize($lemmatext, ' ')[1]"/>
            <xsl:choose>
               <xsl:when test="tokenize($lemmatext, ' ')[2] = ':'">
                  <xsl:value-of select="tokenize($lemmatext, ' ')[2]"/>
                  <xsl:text> </xsl:text>
                  <xsl:value-of select="tokenize($lemmatext, ' ')[3]"/>
               </xsl:when>
               <xsl:when test="tokenize($lemmatext, ' ')[2] = ';'">
                  <xsl:value-of select="tokenize($lemmatext, ' ')[2]"/>
                  <xsl:text> </xsl:text>
                  <xsl:value-of select="tokenize($lemmatext, ' ')[3]"/>
               </xsl:when>
               <xsl:when test="tokenize($lemmatext, ' ')[2] = '!'">
                  <xsl:value-of select="tokenize($lemmatext, ' ')[2]"/>
                  <xsl:text> </xsl:text>
                  <xsl:value-of select="tokenize($lemmatext, ' ')[3]"/>
               </xsl:when>
               <xsl:when test="tokenize($lemmatext, ' ')[2] = '«'">
                  <xsl:value-of select="tokenize($lemmatext, ' ')[2]"/>
                  <xsl:text> </xsl:text>
                  <xsl:value-of select="tokenize($lemmatext, ' ')[3]"/>
               </xsl:when>
               <xsl:when test="tokenize($lemmatext, ' ')[2] = '.'">
                  <xsl:value-of select="tokenize($lemmatext, ' ')[2]"/>
                  <xsl:text> </xsl:text>
                  <xsl:value-of select="tokenize($lemmatext, ' ')[3]"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:text> </xsl:text>
                  <xsl:value-of select="tokenize($lemmatext, ' ')[2]"/>
               </xsl:otherwise>
            </xsl:choose>
            <xsl:text> {\mdseries\ldots} </xsl:text>
            <xsl:value-of select="tokenize($lemmatext, ' ')[last()]"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="$lemmatext"/>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:text>}</xsl:text>
   </xsl:function>
   <xsl:function name="foo:personInEndnote">
      <xsl:param name="first" as="xs:string"/>
      <xsl:param name="verweis" as="xs:boolean"/>
      <xsl:variable name="entry" select="key('person-lookup', $first, $persons)"/>
      <xsl:if test="$verweis">
         <xsl:text>$\rightarrow$</xsl:text>
      </xsl:if>
      <xsl:choose>
         <xsl:when test="$first = ''">
            <xsl:text>\textsuperscript{\textbf{\textcolor{red}{PERSON OFFEN}}}</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:if test="$verweis">
               <xsl:text>\emph{</xsl:text>
            </xsl:if>
            <xsl:choose>
               <xsl:when
                  test="empty($entry/tei:persName/tei:forename) and not(empty($entry/tei:persName/tei:surname))">
                  <xsl:value-of select="normalize-space($entry[1]/tei:persName/tei:surname)"/>
               </xsl:when>
               <xsl:when
                  test="empty($entry/tei:persName/tei:surname) and not(empty($entry/tei:persName/tei:forename))">
                  <xsl:value-of select="normalize-space($entry[1]/tei:persName/tei:forename)"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of
                     select="concat(normalize-space($entry[1]/tei:persName/tei:forename[1]), ' ', normalize-space($entry[1]/tei:persName/tei:surname))"
                  />
               </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="$verweis">
               <xsl:text>}</xsl:text>
            </xsl:if>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:text>.</xsl:text>
   </xsl:function>
   <xsl:function name="foo:indexeintrag-hinten">
      <xsl:param name="first" as="xs:string"/>
      <xsl:param name="verweis" as="xs:boolean"/>
      <xsl:param name="im-text" as="xs:boolean"/>
      <xsl:param name="certlow" as="xs:boolean"/>
      <xsl:param name="kommentar-oder-hrsg" as="xs:boolean"/>
      <xsl:choose>
         <xsl:when test="$certlow = true()">
            <xsl:text>u</xsl:text>
         </xsl:when>
      </xsl:choose>
      <xsl:choose>
         <xsl:when test="$kommentar-oder-hrsg">
            <xsl:text>k</xsl:text>
         </xsl:when>
      </xsl:choose>
      <xsl:choose>
         <xsl:when test="$verweis">
            <xsl:text>v</xsl:text>
         </xsl:when>
      </xsl:choose>
      <xsl:text>}</xsl:text>
   </xsl:function>
   <xsl:function name="foo:stripHash">
      <xsl:param name="first" as="xs:string"/>
      <xsl:value-of select="substring-after($first, '#pmb')"/>
   </xsl:function>
   <xsl:function name="foo:werk-indexName-Routine-autoren">
      <!-- Das soll die Varianten abfangen, dass mehrere Verfasser an einem Werk beteiligt sein können -->
      <xsl:param name="first" as="xs:string"/>
      <xsl:param name="endung" as="xs:string"/>
      <xsl:variable name="work-entry-authors"
         select="key('work-lookup', $first, $works)/tei:author[@role = 'author' or @role = 'hat-geschaffen' or @role = 'abbreviated-name']"/>
      <xsl:variable name="work-entry-authors-count" select="count($work-entry-authors)"/>
      <xsl:choose>
         <xsl:when test="not(key('work-lookup', $first, $works))">
            <xsl:text>\textcolor{red}{\textsuperscript{XXXX indx2}}</xsl:text>
         </xsl:when>
         <xsl:when test="$work-entry-authors-count = 0">
            <xsl:value-of select="foo:werk-in-index($first, $endung, 0)"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:for-each select="$work-entry-authors">
               <xsl:value-of select="foo:werk-in-index($first, $endung, position())"/>
            </xsl:for-each>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <xsl:function name="foo:indexName-Routine">
      <xsl:param name="typ" as="xs:string"/>
      <xsl:param name="first" as="xs:string"/>
      <xsl:param name="rest" as="xs:string"/>
      <xsl:param name="endung" as="xs:string"/>
      <xsl:choose>
         <xsl:when test="$first = '' or empty($first)">
            <xsl:text>\textcolor{red}{\textsuperscript{\textbf{KEY}}}</xsl:text>
         </xsl:when>
         <xsl:when test="$typ = 'person'">
            <xsl:choose>
               <xsl:when test="$first = '#pmb2121'">
                  <!-- Einträge  Schnitzler raus -->
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of
                     select="foo:person-in-index(replace($first, '#', ''), $endung, true())"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:when>
         <xsl:when test="$typ = 'work'">
            <xsl:value-of
               select="foo:werk-indexName-Routine-autoren(replace($first, '#', ''), $endung)"/>
         </xsl:when>
         <xsl:when test="$typ = 'org'">
            <xsl:value-of select="foo:org-in-index(replace($first, '#', ''), $endung)"/>
         </xsl:when>
         <xsl:when test="$typ = 'place'">
            <xsl:value-of select="foo:place-in-index(replace($first, '#', ''), $endung, true())"/>
         </xsl:when>
         <xsl:when test="$typ = 'event'">
            <xsl:value-of select="foo:event-in-index(replace($first, '#', ''), $endung)"/>
         </xsl:when>
      </xsl:choose>
      <xsl:if test="normalize-space($rest) != ''">
         <xsl:value-of
            select="foo:indexName-Routine($typ, tokenize($rest, ' ')[1], substring-after($rest, ' '), $endung)"
         />
      </xsl:if>
   </xsl:function>
   <!-- Hier wird, je nachdem ob es sich um vorne oder hinten im Text handelt, ein Indexmarker gesetzt, der zeigt,
   dass ein Werk über mehrere Seiten geht bzw. dieser geschlossen -->
   <xsl:function name="foo:abgedruckte-workNameRoutine">
      <xsl:param name="first" as="xs:string"/>
      <xsl:param name="vorne" as="xs:boolean"/>
      <xsl:choose>
         <xsl:when test="$first = ''">
            <xsl:text>\textcolor{red}{INDEX FEHLER W}</xsl:text>
         </xsl:when>
         <xsl:when test="not(starts-with($first, 'pmb'))">
            <xsl:text>\textcolor{red}{WERKINDEX FEHLER}</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:variable name="entry" select="key('work-lookup', replace($first, '#', ''), $works)"
               as="node()?"/>
            <xsl:variable name="author"
               select="$entry/tei:author[@role = 'author' or @role = 'hat-geschaffen' or @role = 'abbreviated-name']"/>
            <xsl:choose>
               <xsl:when test="not($entry) or $entry = ''">
                  <xsl:text>\pwindex{XXXX Abgedrucktes Werk, Nummer nicht vorhanden|pwt}</xsl:text>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:choose>
                     <!-- Hier nun gleich der Fall von einem Autor, mehreren Autoren abgefangen -->
                     <xsl:when test="not($author)">
                        <xsl:value-of select="foo:werk-in-index($first, '|pwt', 0)"/>
                        <xsl:choose>
                           <xsl:when test="$vorne">
                              <xsl:text>(</xsl:text>
                           </xsl:when>
                           <xsl:otherwise>
                              <xsl:text>)</xsl:text>
                           </xsl:otherwise>
                        </xsl:choose>
                        <xsl:text>}</xsl:text>
                     </xsl:when>
                     <xsl:otherwise>
                        <xsl:for-each
                           select="$entry/tei:author[@role = 'author' or @role = 'hat-geschaffen' or @role = 'abbreviated-name']">
                           <xsl:value-of select="foo:werk-in-index($first, '|pwt', position())"/>
                           <xsl:choose>
                              <xsl:when test="$vorne">
                                 <xsl:text>(</xsl:text>
                              </xsl:when>
                              <xsl:otherwise>
                                 <xsl:text>)</xsl:text>
                              </xsl:otherwise>
                           </xsl:choose>
                           <xsl:text>}</xsl:text>
                        </xsl:for-each>
                     </xsl:otherwise>
                  </xsl:choose>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:otherwise>
      </xsl:choose>
      <!--<xsl:if test="$rest != ''">
            <xsl:value-of
               select="foo:abgedruckte-workNameRoutine(substring($rest, 1, 7), substring-after($rest, ' '), $vorne)"
            />
         </xsl:if>-->
   </xsl:function>
   <xsl:function name="foo:werkInEndnote">
      <xsl:param name="first" as="xs:string"/>
      <xsl:param name="verweis" as="xs:boolean"/>
      <xsl:variable name="entry" select="key('work-lookup', $first, $works)"/>
      <xsl:variable name="author-entry" select="$entry/tei:author"/>
      <xsl:if
         test="$entry/tei:author[@role = 'author' or @role = 'hat-geschaffen' or @role = 'abbreviated-name']/tei:surname/text() != ''">
         <xsl:for-each
            select="$entry/tei:author[@role = 'author' or @role = 'hat-geschaffen' or @role = 'abbreviated-name']">
            <xsl:choose>
               <xsl:when test="tei:persName/tei:forename = '' and tei:persName/tei:surname = ''">
                  <xsl:text>\textcolor{red}{KEIN NAME}</xsl:text>
               </xsl:when>
               <xsl:when test="tei:forename = ''">
                  <xsl:apply-templates select="tei:surname"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:apply-templates select="concat(tei:forename, ' ', tei:surname)"/>
               </xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
               <xsl:when test="position() = last()">
                  <xsl:text>:</xsl:text>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:text>, </xsl:text>
               </xsl:otherwise>
            </xsl:choose>
            <xsl:text> </xsl:text>
         </xsl:for-each>
      </xsl:if>
      <xsl:choose>
         <xsl:when test="contains($entry/tei:title, ':]') and starts-with($entry/tei:title, '[')">
            <xsl:value-of select="substring-before($entry/tei:title, ':] ')"/>
            <xsl:text>]: \emph{</xsl:text>
            <xsl:value-of select="substring-after($entry/tei:title, ':] ')"/>
            <xsl:text>}</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>\emph{</xsl:text>
            <xsl:value-of select="$entry/tei:title"/>
            <xsl:text>}</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="$entry/Bibliografie != ''">
         <xsl:text>, </xsl:text>
         <xsl:value-of select="foo:date-translate($entry/Bibliografie)"/>
      </xsl:if>
   </xsl:function>
   <!-- EVENTS -->
   <xsl:function name="foo:eventNameRoutine">
      <xsl:param name="first" as="xs:string"/>
      <xsl:param name="rest" as="xs:string"/>
      <xsl:param name="endung" as="xs:string"/>
      <xsl:if test="$first != ''">
         <xsl:value-of select="foo:event-in-index($first, $endung)"/>
         <xsl:if test="$rest != ''">
            <xsl:value-of
               select="foo:eventNameRoutine(tokenize($rest, ' ')[1], substring-after($rest, ' '), $endung)"
            />
         </xsl:if>
      </xsl:if>
   </xsl:function>
   <!-- ORGANISATIONEN -->
   <xsl:function name="foo:orgInEndnote">
      <xsl:param name="first" as="xs:string"/>
      <xsl:param name="verweis" as="xs:boolean"/>
      <xsl:variable name="entry" select="key('org-lookup', $first, $orgs)"/>
      <xsl:if test="$verweis">
         <xsl:text>{$\rightarrow$}\emph{</xsl:text>
      </xsl:if>
      <xsl:choose>
         <xsl:when test="$first = ''">
            <xsl:text>\textcolor{red}{ORGANISATION OFFEN}</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:if test="$entry[1]/tei:orgName[1] != ''">
               <xsl:value-of
                  select="foo:sonderzeichen-ersetzen(normalize-space($entry[1]//tei:orgName))"/>
            </xsl:if>
            <xsl:if test="$entry[1]/Ort[1] != ''">
               <xsl:text>, </xsl:text>
               <xsl:value-of select="foo:sonderzeichen-ersetzen(normalize-space($entry[1]/*:Ort))"/>
            </xsl:if>
            <xsl:if test="$entry[1]/Ort[1] != ''">
               <xsl:text>, \emph{</xsl:text>
               <xsl:value-of select="foo:sonderzeichen-ersetzen(normalize-space($entry[1]/*:Typ))"/>
               <xsl:text>}</xsl:text>
            </xsl:if>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="$verweis">
         <xsl:text>}</xsl:text>
      </xsl:if>
      <xsl:text>.</xsl:text>
   </xsl:function>
   <!-- ORTE: -->
   <!-- Da mehrere place-keys angegeben sein können, kommt diese Routine zum Einsatz: -->
   <xsl:function name="foo:placeNameRoutine">
      <xsl:param name="first" as="xs:string"/>
      <xsl:param name="rest" as="xs:string"/>
      <xsl:param name="endung" as="xs:string"/>
      <xsl:param name="endung-setzen" as="xs:boolean"/>
      <xsl:choose>
         <xsl:when test="$first = ''">
            <xsl:text>\textcolor{red}{ORT FEHLER}</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of
               select="foo:place-in-index(replace($first, '#', ''), $endung, $endung-setzen)"/>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="$rest != ''">
         <xsl:value-of
            select="foo:placeNameRoutine(tokenize($rest, ' ')[1], substring-after($rest, ' '), $endung, $endung-setzen)"
         />
      </xsl:if>
   </xsl:function>
   <xsl:function name="foo:normalize-und-umlaute">
      <xsl:param name="wert" as="xs:string"/>
      <xsl:value-of select="normalize-space(foo:umlaute-entfernen($wert))"/>
   </xsl:function>
   <xsl:function name="foo:place-for-index">
      <!-- Diese Funktion formatiert die Indexangabe vor und nach dem Klammeraffen @ tuebingen@Tübingen -->
      <xsl:param name="first" as="xs:string"/>
      <xsl:variable name="ort" select="key('place-lookup', $first, $places)/tei:placeName[1]"/>
      <xsl:choose>
         <xsl:when test="string-length($ort) = 0">
            <xsl:text>XXXX Ortsangabe fehlt</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of
               select="normalize-space(foo:umlaute-entfernen(foo:sonderzeichen-ersetzen($ort)))"/>
            <xsl:text>@</xsl:text>
            <xsl:text>\textbf{</xsl:text>
            <xsl:value-of select="normalize-space(foo:sonderzeichen-ersetzen($ort))"/>
            <xsl:text>}</xsl:text>
            <xsl:if test="key('place-lookup', $first, $places)/tei:desc[@type = 'entity_type'][1]">
               <xsl:variable name="placeTypeName"
                  select="key('placeType-lookup', key('place-lookup', $first, $places)/tei:desc[1]/text(), $placeTypes)/*:name"/>
               <xsl:if
                  test="$placeTypeName != 'Besiedelter Ort' and $placeTypeName != 'Unabhängige politische Einheit'">
                  <xsl:text>, \emph{</xsl:text>
                  <xsl:value-of select="$placeTypeName"/>
                  <xsl:text>}</xsl:text>
               </xsl:if>
            </xsl:if>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <xsl:function name="foo:place-in-index">
      <xsl:param name="first" as="xs:string"/>
      <xsl:param name="endung" as="xs:string"/>
      <xsl:param name="endung-setzen" as="xs:boolean"/>
      <xsl:variable name="place" select="key('place-lookup', $first, $places)"/>
      <xsl:variable name="ort" select="$place/tei:placeName[1]"/>
      <xsl:choose>
         <xsl:when test="not(starts-with($first, 'pmb'))">
            <xsl:text>\textcolor{red}{FEHLER4}</xsl:text>
         </xsl:when>
         <xsl:when test="
               count($place/tei:location[@type = 'located_in_place' and
               matches(tei:placeName/@ref, '^pmb(5[1-9]|6[0-9]|7[0-3])$')]) &gt; 0">
            <xsl:for-each select="
                  $place/tei:location[@type = 'located_in_place' and
                  matches(tei:placeName/@ref, '^pmb(5[1-9]|6[0-9]|7[0-3])$')]">
               <!-- ein Ort in einem Wiener Bezirk -->
               <xsl:text>\oindex{</xsl:text>
               <xsl:value-of select="foo:index-sortiert('Wien', 'bf')"/>
               <xsl:text>!</xsl:text>
               <xsl:value-of select="foo:index-sortiert(tei:placeName, 'bf')"/>
               <xsl:text>!</xsl:text>
               <xsl:value-of select="foo:place-for-index(replace($first, '#', ''))"/>
               <xsl:if test="$endung-setzen">
                  <xsl:value-of select="$endung"/>
               </xsl:if>
            </xsl:for-each>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>\oindex{</xsl:text>
            
               <xsl:variable name="zu-beruecksichtigen" as="node()">
                  <list>
                     <xsl:for-each select="$place/tei:location[@type='located_in_place']">
                     <xsl:choose>
                        <xsl:when test="key('placeType-lookup', tei:placeName[1]/@ref, $placeTypes)"></xsl:when>
                        <xsl:otherwise>
                           <item>
                              <xsl:copy-of select="*"/>
                              
                           </item>
                        </xsl:otherwise>
                     </xsl:choose>
                        
                     
                     </xsl:for-each>
                  </list>
               </xsl:variable>
               
               
            <!--<xsl:value-of select="foo:place-in-index($place/tei:placeName/@ref, '', false())"/>-->
               
            
            <xsl:value-of select="foo:place-for-index(replace($first, '#', ''))"/>
            <xsl:if test="$endung-setzen">
               <xsl:value-of select="$endung"/>
            </xsl:if>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <xsl:function name="foo:textkonstitution-tabelle">
      <xsl:param name="lemma" as="xs:string"/>
      <xsl:param name="textconst-inhalt" as="xs:string"/>
      <xsl:param name="linenum-vorne" as="xs:string"/>
      <xsl:param name="linenum-hinten" as="xs:string"/>
      <xsl:text>\edtext{}{\linenum{|\xlineref{</xsl:text>
      <xsl:value-of select="$linenum-vorne"/>
      <xsl:text>}|||\xlineref{</xsl:text>
      <xsl:value-of select="$linenum-hinten"/>
      <xsl:text>}||}\lemma{</xsl:text>
      <xsl:value-of select="foo:sonderzeichen-ersetzen(normalize-space($lemma))"/>
      <xsl:text>}\Cendnote{</xsl:text>
      <xsl:apply-templates select="$textconst-inhalt"/>
      <xsl:text>}}</xsl:text>
   </xsl:function>
   <xsl:template match="tei:facsimile"/>
   <!-- Horizontale Linie -->
   <xsl:template match="tei:milestone[@rend = 'line']">
      <xsl:text>\noindent\rule{\textwidth}{0.5pt}</xsl:text>
   </xsl:template>
   <!-- Bilder einbetten -->
   <xsl:template match="tei:figure">
      <xsl:variable name="numbers" as="xs:integer*">
         <xsl:analyze-string select="graphic/@width" regex="([0-9]+)cm">
            <xsl:matching-substring>
               <xsl:sequence select="xs:integer(regex-group(1))"/>
            </xsl:matching-substring>
         </xsl:analyze-string>
      </xsl:variable>
      <xsl:variable name="caption" as="node()?" select="parent::tei:div/tei:caption"/>
      <!-- Drei Varianten:
         - Bild ohne Bildtext zentriert
         - Bild mit Bildtext, hatei:lbe Textbreite, Bildtext daneben
         - Bild mit Bildtext, Bildtext drunter
        Wenn
         
         Wenn das Bild max. bis zur hatei:lben Textbreite geht, wird die Bildunterschrift daneben gesetzt = Variante 1 -->
      <xsl:choose>
         <xsl:when test="not($caption)">
            <xsl:choose>
               <!-- Bilder in Herausgebertexten sind nicht auf Platz fixiert -->
               <xsl:when test="ancestor::tei:TEI/starts-with(@xml:id, 'E_')">
                  <xsl:text>\noindent</xsl:text>
                  <xsl:text>\begin{figure}[htbp]</xsl:text>
                  <xsl:text>\centering</xsl:text>
                  <xsl:apply-templates/>
                  <xsl:text>\end{figure}</xsl:text>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:text>\begin{figure}[H]\centering</xsl:text>
                  <xsl:apply-templates/>
                  <xsl:text>\end{figure}</xsl:text>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:when>
         <xsl:when test="$numbers &lt; 7">
            <xsl:choose>
               <!-- Herausgebertext:  -->
               <xsl:when test="ancestor::tei:TEI/starts-with(@xml:id, 'E_')">
                  <xsl:text>\begin{figure}[htbp]</xsl:text>
                  <xsl:text>\noindent\begin{minipage}[t]{</xsl:text>
                  <xsl:value-of select="$numbers"/>
                  <xsl:text>cm}</xsl:text>
                  <xsl:text>\noindent</xsl:text>
                  <xsl:apply-templates/>
                  <xsl:text>\end{minipage</xsl:text>
                  <xsl:text>\noindent\begin{minipage}[t]{\dimexpr\hatei:lbtextwidth-</xsl:text>
                  <xsl:value-of select="graphic/@width"/>
                  <xsl:text>\relax}</xsl:text>
                  <xsl:apply-templates select="$caption" mode="halbetextbreite"/>
                  <xsl:text>\end{minipage}</xsl:text>
                  <xsl:text>\end{figure}</xsl:text>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:text>\noindent\begin{minipage}[t]{</xsl:text>
                  <xsl:value-of select="$numbers"/>
                  <xsl:text>cm}</xsl:text>
                  <xsl:apply-templates/>
                  <xsl:text>\end{minipage}</xsl:text>
                  <xsl:text>\noindent\begin{minipage}[t]{\dimexpr\hatei:lbtextwidth-</xsl:text>
                  <xsl:value-of select="graphic/@width"/>
                  <xsl:text>\relax}</xsl:text>
                  <xsl:apply-templates select="$caption" mode="halbetextbreite"/>
                  <xsl:text>\end{minipage}</xsl:text>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:when>
         <xsl:otherwise>
            <xsl:choose>
               <!-- Bilder in Herausgebertexten sind nicht auf Platz fixiert -->
               <xsl:when test="ancestor::tei:TEI/starts-with(@xml:id, 'E_')">
                  <xsl:text>\noindent</xsl:text>
                  <xsl:text>\begin{figure}[htbp]</xsl:text>
                  <xsl:text>\centering</xsl:text>
                  <xsl:text>\noindent</xsl:text>
                  <xsl:apply-templates/>
                  <xsl:apply-templates select="$caption"/>
                  <xsl:text>\end{figure}</xsl:text>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:text>\begin{figure}[H]\centering</xsl:text>
                  <xsl:apply-templates/>
                  <xsl:apply-templates select="$caption"/>
                  <xsl:text>\end{figure}</xsl:text>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:template match="tei:caption" mode="halbetextbreite">
      <!-- Falls es eine Bildunterschrift gibt -->
      <xsl:text>\hspace{0.5cm}\begin{minipage}[b]{0.85\textwidth}\noindent</xsl:text>
      <xsl:text>\begin{RaggedRight}\small\emph{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}\end{RaggedRight}\end{minipage}\vspace{\baselineskip}
      </xsl:text>
   </xsl:template>
   <xsl:template match="tei:caption">
      <!-- Falls es eine Bildunterschrift gibt -->
      <xsl:text>\hspace{0.5cm}\noindent</xsl:text>
      <xsl:text>\begin{center}\small\emph{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}\end{center}\vspace{\baselineskip}
      </xsl:text>
   </xsl:template>
   <xsl:template match="tei:graphic">
      <xsl:text>\includegraphics</xsl:text>
      <xsl:choose>
         <xsl:when test="@width">
            <xsl:text>[width=</xsl:text>
            <xsl:value-of select="@width"/>
            <xsl:text>]</xsl:text>
         </xsl:when>
         <xsl:when test="@height">
            <xsl:text>[height=</xsl:text>
            <xsl:value-of select="@height"/>
            <xsl:text>]</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>[max height=\linewidth,max width=\linewidth]
</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:text>{</xsl:text>
      <xsl:value-of
         select="concat('../tex-inputs/img/', replace(@url, '../resources/img', 'images'), '.jpg')"/>
      <xsl:text>}</xsl:text>
   </xsl:template>
   <xsl:template match="tei:list">
      <xsl:text>\begin{itemize}[noitemsep, leftmargin=*]</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>\end{itemize}</xsl:text>
   </xsl:template>
   <xsl:template match="tei:item">
      <xsl:text>\item </xsl:text>
      <xsl:apply-templates/>
      <xsl:text>&#10; </xsl:text>
   </xsl:template>
   <xsl:template match="tei:list[@type = 'gloss']">
      <xsl:text>&#10;\setlist[description]{font=\normalfont\upshape\mdseries,style=nextline}\begin{description}</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>&#10;\end{description}</xsl:text>
   </xsl:template>
   <xsl:template match="tei:list[@type = 'gloss']/tei:label">
      <xsl:text>&#10;\item[</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>]</xsl:text>
   </xsl:template>
   <xsl:template match="tei:list[@type = 'gloss']/tei:item">
      <xsl:text>{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
   </xsl:template>
   <xsl:template match="tei:list[@type = 'simple-gloss']">
      <xsl:text>&#10;\begin{description}[font=\normalfont\upshape\mdseries, itemsep=0em, labelwidth=5em, itemsep=0em,leftmargin=5.6em]</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>&#10;\end{description}</xsl:text>
   </xsl:template>
   <xsl:template match="tei:list[@type = 'simple-gloss']/tei:label">
      <xsl:text>&#10;\item[</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>]</xsl:text>
   </xsl:template>
   <xsl:template match="tei:list[@type = 'simple-gloss']/tei:item">
      <xsl:text>{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
   </xsl:template>
   <xsl:template match="tei:ref[@type = 'pointer']">
      <!-- Pointer funktionieren so, dass sie, wenn sie auf v enden, auf einen Bereich zeigen, sonst
      wird einfach zweimal der setei:lbe Punkt gesetzt-->
      <xsl:choose>
         <xsl:when test="@subtype = 'see'">
            <xsl:text>siehe </xsl:text>
         </xsl:when>
         <xsl:when test="@subtype = 'cf'">
            <xsl:text>vgl. </xsl:text>
         </xsl:when>
         <xsl:when test="@subtype = 'See'">
            <xsl:text>Siehe </xsl:text>
         </xsl:when>
         <xsl:when test="@subtype = 'Cf'">
            <xsl:text>Vgl. </xsl:text>
         </xsl:when>
      </xsl:choose>
      <xsl:text>$\triangleright$</xsl:text>
      <xsl:variable name="start-label" select="substring-after(@target, '#')"/>
      <xsl:choose>
         <xsl:when test="$start-label = ''">
            <xsl:text>\textcolor{red}{XXXX Labelref}</xsl:text>
         </xsl:when>
         <xsl:when test="ends-with(@target, 'v')">
            <xsl:variable name="end-label"
               select="concat(substring-after(substring-before(@target, 'v'), '#'), 'h')"/>
            <xsl:text>\myrangeref{</xsl:text>
            <xsl:value-of select="$start-label"/>
            <xsl:text>}{</xsl:text>
            <xsl:value-of select="$end-label"/>
            <xsl:text>}</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>\myrangeref{</xsl:text>
            <xsl:value-of select="$start-label"/>
            <xsl:text>v}{</xsl:text>
            <xsl:value-of select="$start-label"/>
            <xsl:text>h}</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:template match="tei:ref[@type = 'schnitzler-tagebuch' or @type = 'wienerschnitzler']">
      <xsl:if test="not(@subtype = 'date-only')">
         <xsl:choose>
            <xsl:when test="@subtype = 'see'">
               <xsl:text>siehe </xsl:text>
            </xsl:when>
            <xsl:when test="@subtype = 'cf'">
               <xsl:text>vgl. </xsl:text>
            </xsl:when>
            <xsl:when test="@subtype = 'See'">
               <xsl:text>Siehe </xsl:text>
            </xsl:when>
            <xsl:when test="@subtype = 'Cf'">
               <xsl:text>Vgl. </xsl:text>
            </xsl:when>
         </xsl:choose>
         <xsl:text>A.&#8239;S.: </xsl:text>
         <xsl:choose>
            <xsl:when test="@type = 'schnitzler-tagebuch'">
               <xsl:text>\emph{Tagebuch}, </xsl:text>
            </xsl:when>
            <xsl:when test="@type = 'wienerschnitzler'">
               <xsl:text>\emph{Wiener Schnitzler}, </xsl:text>
            </xsl:when>
         </xsl:choose>
      </xsl:if>
      <xsl:value-of select="
            format-date(@target,
            '[D1].&#8239;[M1].&#8239;[Y0001]')"/>
   </xsl:template>
   <xsl:template match="tei:ref[@type = 'schnitzler-lektueren']">
      <xsl:if test="not(@subtype = 'date-only')">
         <xsl:choose>
            <xsl:when test="@subtype = 'see'">
               <xsl:text>siehe </xsl:text>
            </xsl:when>
            <xsl:when test="@subtype = 'cf'">
               <xsl:text>vgl. </xsl:text>
            </xsl:when>
            <xsl:when test="@subtype = 'See'">
               <xsl:text>Siehe </xsl:text>
            </xsl:when>
            <xsl:when test="@subtype = 'Cf'">
               <xsl:text>Vgl. </xsl:text>
            </xsl:when>
         </xsl:choose>
         <xsl:text>A.&#8239;S.: \emph{Lektüren}, </xsl:text>
      </xsl:if>
      <xsl:choose>
         <xsl:when test="@target = 'Deutschsprachige-Literatur'">
            <xsl:text>deutschsprachige Literatur</xsl:text>
         </xsl:when>
         <xsl:when test="@target = 'Polen-Czechen'">
            <xsl:text>Polen, Czechen</xsl:text>
         </xsl:when>
         <xsl:when test="@target = 'Ungarn-etc.'">
            <xsl:text>Ungarn etc.</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="replace(@target, '.html', '')"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:template match="tei:ref[@type = 'schnitzler-kultur']">
      <xsl:variable name="target" select="replace(@target, '#', '')"/>
      <xsl:choose>
         <xsl:when test="@subtype = 'date-only'"/>
         <xsl:otherwise>
            <xsl:choose>
               <xsl:when test="@subtype = 'see'">
                  <xsl:text>siehe </xsl:text>
               </xsl:when>
               <xsl:when test="@subtype = 'cf'">
                  <xsl:text>vgl. </xsl:text>
               </xsl:when>
               <xsl:when test="@subtype = 'See'">
                  <xsl:text>Siehe </xsl:text>
               </xsl:when>
               <xsl:when test="@subtype = 'Cf'">
                  <xsl:text>Vgl. </xsl:text>
               </xsl:when>
            </xsl:choose>
            <xsl:text>A.&#8239;S.: \emph{Kulturveranstaltungen}, </xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:variable name="date-from-event" as="xs:date"
         select="document('https://raw.githubusercontent.com/arthur-schnitzler/schnitzler-kultur/main/data/editions/listevent.xml')/tei:TEI/tei:text[1]/tei:body[1]/tei:listEvent[1]/tei:event[@xml:id = $target]/@when-iso"/>
      <xsl:value-of select="
            format-date($date-from-event,
            '[D1].&#8239;[M1].&#8239;[Y0001]')"/>
   </xsl:template>
   <xsl:template match="tei:ref[@type = 'schnitzler-interviews']">
      <xsl:if test="not(@subtype = 'date-only')">
         <xsl:choose>
            <xsl:when test="@subtype = 'see'">
               <xsl:text>siehe </xsl:text>
            </xsl:when>
            <xsl:when test="@subtype = 'cf'">
               <xsl:text>vgl. </xsl:text>
            </xsl:when>
            <xsl:when test="@subtype = 'See'">
               <xsl:text>Siehe </xsl:text>
            </xsl:when>
            <xsl:when test="@subtype = 'Cf'">
               <xsl:text>Vgl. </xsl:text>
            </xsl:when>
         </xsl:choose>
         <xsl:text>A.&#8239;S.: \emph{»Das Zeitlose ist von kürzester Dauer«}, </xsl:text>
      </xsl:if>
      <xsl:value-of
         select="normalize-space(document(concat('https://raw.githubusercontent.com/arthur-schnitzler/schnitzler-interviews-data/main/data/editions/', replace(@target, '.html', ''), '.xml'))/descendant::tei:titleStmt/tei:title[@level = 'a'][1])"
      />
   </xsl:template>
   <xsl:template match="tei:ref[@type = 'schnitzler-bahr']">
      <xsl:if test="not(@subtype = 'date-only')">
         <xsl:choose>
            <xsl:when test="@subtype = 'see'">
               <xsl:text>siehe </xsl:text>
            </xsl:when>
            <xsl:when test="@subtype = 'cf'">
               <xsl:text>vgl. </xsl:text>
            </xsl:when>
            <xsl:when test="@subtype = 'See'">
               <xsl:text>Siehe </xsl:text>
            </xsl:when>
            <xsl:when test="@subtype = 'Cf'">
               <xsl:text>Vgl. </xsl:text>
            </xsl:when>
         </xsl:choose>
         <xsl:text>Hermann Bahr, Arthur Schnitzler: \emph{Briefwechsel, Aufzeichnungen, Dokumente (1891–1931)}, </xsl:text>
      </xsl:if>
      <xsl:value-of
         select="normalize-space(document(concat('https://raw.githubusercontent.com/arthur-schnitzler/schnitzler-bahr-data/main/data/editions/', replace(@target, '.html', ''), '.xml'))/descendant::tei:titleStmt/tei:title[@level = 'a'][1])"
      />
   </xsl:template>
   <xsl:template match="tei:ref[@type = 'url']">
      <xsl:text>\uline{\url{</xsl:text>
      <xsl:value-of select="(@target)"/>
      <xsl:text>}}</xsl:text>
   </xsl:template>
   <xsl:template match="tei:ref[@type = 'schnitzler-briefe']">
      <xsl:variable name="current-folder" select="substring-before(document-uri(/), '/meta')"/>
      <xsl:variable name="target-path" as="xs:string">
         <xsl:choose>
            <xsl:when test="ends-with(@target, '.xml')">
               <xsl:value-of select="concat('../editions/', @target)"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="concat('../editions/', @target, '.xml')"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:choose>
         <xsl:when test="@target = ''">
            <xsl:text>{XXXX ref}</xsl:text>
         </xsl:when>
         <xsl:when test="@subtype = 'date-only'">
            <xsl:try>
               <xsl:variable name="doc"
                  select="document(resolve-uri($target-path, document-uri(/)))"/>
               <xsl:choose>
                  <xsl:when
                     test="$doc//tei:correspDesc/tei:correspAction[@type = 'sent']/tei:date/text()">
                     <xsl:value-of
                        select="$doc//tei:correspDesc/tei:correspAction[@type = 'sent']/tei:date/text()"
                     />
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:text>XXXX Auszeichnungsfehler: Datum nicht gefunden</xsl:text>
                  </xsl:otherwise>
               </xsl:choose>
               <xsl:catch>
                  <xsl:text>XXXX Auszeichnungsfehler: Dokument </xsl:text>
                  <xsl:value-of select="@target"/>
                  <xsl:text> nicht gefunden</xsl:text>
               </xsl:catch>
            </xsl:try>
         </xsl:when>
         <xsl:otherwise>
            <xsl:choose>
               <xsl:when test="@subtype = 'see'">
                  <xsl:text>siehe </xsl:text>
               </xsl:when>
               <xsl:when test="@subtype = 'cf'">
                  <xsl:text>vgl. </xsl:text>
               </xsl:when>
               <xsl:when test="@subtype = 'See'">
                  <xsl:text>Siehe </xsl:text>
               </xsl:when>
               <xsl:when test="@subtype = 'Cf'">
                  <xsl:text>Vgl. </xsl:text>
               </xsl:when>
            </xsl:choose>
            <xsl:try>
               <xsl:variable name="doc" select="document($target-path)"/>
               <xsl:choose>
                  <xsl:when test="$doc//tei:titleStmt/tei:title[@level = 'a']">
                     <xsl:value-of select="$doc//tei:titleStmt/tei:title[@level = 'a']"/>
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:text>XXXX Auszeichnungsfehler: Titel nicht gefunden</xsl:text>
                  </xsl:otherwise>
               </xsl:choose>
               <xsl:catch>
                  <xsl:text>XXXX Auszeichnungsfehler: Dokument </xsl:text>
                  <xsl:value-of select="@target"/>
                  <xsl:text> nicht gefunden</xsl:text>
               </xsl:catch>
            </xsl:try>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <!-- Das hier reicht die LateX-Befehler direkt durch, die mit <?latex ....> markiert sind -->
   <xsl:template match="processing-instruction()[name() = 'latex']">
      <xsl:value-of select="concat('{', normalize-space(.), '}')"/>
   </xsl:template>
   <xsl:function name="foo:incident-rend">
      <xsl:param name="rend" as="xs:string?"/>
      <xsl:choose>
         <xsl:when test="$rend = 'bleistift'">
            <xsl:text>mit Bleistift </xsl:text>
         </xsl:when>
         <xsl:when test="$rend = 'roter-buntstift'">
            <xsl:text>mit rotem Buntstift </xsl:text>
         </xsl:when>
         <xsl:when test="$rend = 'blauer-buntstift'">
            <xsl:text>mit blauem Buntstift </xsl:text>
         </xsl:when>
         <xsl:when test="$rend = 'gruener-buntstift'">
            <xsl:text>mit grünem Buntstift </xsl:text>
         </xsl:when>
         <xsl:when test="$rend = 'schwarze-tinte'">
            <xsl:text>mit schwarzer Tinte </xsl:text>
         </xsl:when>
         <xsl:when test="$rend = 'blaue-tinte'">
            <xsl:text>mit blauer Tinte </xsl:text>
         </xsl:when>
         <xsl:when test="$rend = 'gruene-tinte'">
            <xsl:text>mit grüner Tinte </xsl:text>
         </xsl:when>
         <xsl:when test="$rend = 'lila-tinte'">
            <xsl:text>mit lila Tinte</xsl:text>
         </xsl:when>
         <xsl:when test="$rend = 'rote-tinte'">
            <xsl:text>mit roter Tinte </xsl:text>
         </xsl:when>
      </xsl:choose>
   </xsl:function>
</xsl:stylesheet>
