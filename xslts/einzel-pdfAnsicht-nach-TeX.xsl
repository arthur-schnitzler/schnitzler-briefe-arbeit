<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions"
   xmlns:foo="whatever" xmlns:tei="http://www.tei-c.org/ns/1.0" version="3.0">
   <xsl:include href="einzel-shared-nach-tex.xsl"/>
   
   
   <xsl:template match="tei:persName | tei:workName | tei:orgName | tei:placeName | tei:rs">
      <xsl:variable name="first" select="tokenize(@ref, ' ')[1]" as="xs:string?"/>
      <xsl:variable name="rest" select="substring-after(@ref, concat($first, ' '))" as="xs:string"/>
      <xsl:variable name="index-test-bestanden" as="xs:boolean"
         select="count(ancestor::tei:TEI/tei:teiHeader/tei:revisionDesc/tei:change[contains(text(), 'Index check')]) &gt; 0"/>
      <xsl:variable name="candidate" as="xs:boolean" select="true()"/>
      <!--<xsl:variable name="candidate" as="xs:boolean"
         select="ancestor::tei:TEI/tei:teiHeader/tei:revisionDesc/@status = 'approved' or ancestor::tei:TEI/tei:teiHeader/tei:revisionDesc/@status = 'candidate' or ancestor::tei:TEI/tei:teiHeader/tei:revisionDesc/tei:change[contains(text(), 'Index check')]"/>-->
      <!-- In diesen Fällen befindet sich das rs im Text: -->
      <xsl:variable name="im-text" as="xs:boolean"
         select="ancestor::tei:body and not(ancestor::tei:note) and not(ancestor::tei:caption) and not(parent::tei:bibl) and not(ancestor::tei:TEI[starts-with(@xml:id, 'E')]) and not(ancestor::tei:div[@type = 'biographical'])"/>
      <!-- In diesen Fällen werden orgs und titel kursiv geschrieben: -->
      <xsl:variable name="kommentar-herausgeber" as="xs:boolean"
         select="(ancestor::tei:note[@type = 'commentary'] or ancestor::tei:note[@type = 'textConst'] or ancestor::tei:TEI[starts-with(@xml:id, 'E')] or ancestor::tei:bibl or ancestor::tei:div[@type = 'biographical']) and not(ancestor::tei:quote)"/>
      <!-- Ist's implizit vorkommend -->
      <xsl:variable name="verweis" as="xs:boolean" select="@subtype = 'implied'"/>
      <!-- Kursiv ja / nein -->
      <xsl:variable name="emph"
         select="not(@subtype = 'implied') and $kommentar-herausgeber and (@type = 'work' or @type = 'org' or @type='event')"/>
      <xsl:variable name="cert" as="xs:boolean" select="(@cert = 'low') or (@cert = 'medium')"/>
      <xsl:variable name="endung-index" as="xs:string">
         <xsl:choose>
            <xsl:when test="$cert and $verweis and $kommentar-herausgeber">
               <xsl:text>|pwuvk}</xsl:text>
            </xsl:when>
            <xsl:when test="$cert and $verweis">
               <xsl:text>|pwuv}</xsl:text>
            </xsl:when>
            <xsl:when test="$cert and $kommentar-herausgeber">
               <xsl:text>|pwuk}</xsl:text>
            </xsl:when>
            <xsl:when test="$cert">
               <xsl:text>|pwu}</xsl:text>
            </xsl:when>
            <xsl:when test="$verweis and $kommentar-herausgeber">
               <xsl:text>|pwkv}</xsl:text>
            </xsl:when>
            <xsl:when test="$verweis">
               <xsl:text>|pwv}</xsl:text>
            </xsl:when>
            <xsl:when test="$kommentar-herausgeber">
               <xsl:text>|pwk}</xsl:text>
            </xsl:when>
            <xsl:otherwise>
               <xsl:text>|pw}</xsl:text>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:choose>
         <xsl:when test="$first = '' or empty($first)">
            <!-- Hier der Fall, dass die @ref-Nummer fehlt -->
            <xsl:apply-templates/>
            <xsl:text>\textcolor{red}{\textsuperscript{\textbf{KEY}}}</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:choose>
               <xsl:when test="$candidate">
                  <xsl:if test="$emph">
                     <xsl:text>\emph{</xsl:text>
                  </xsl:if>
                  <xsl:apply-templates/>
                  <xsl:if test="$emph">
                     <xsl:text>}</xsl:text>
                  </xsl:if>
                  <xsl:value-of
                     select="foo:indexName-Routine(@type, tokenize(@ref, ' ')[1], substring-after(@ref, ' '), $endung-index)"
                  />
               </xsl:when>
               <xsl:otherwise>
                  <xsl:if
                     test="$im-text and not(@ref = '#pmb2121' or @ref = '#pmb50') and not($index-test-bestanden)">
                     <!--                     <xsl:text>\edtext{</xsl:text>-->
                  </xsl:if>
                  <xsl:if test="$emph">
                     <xsl:text>\emph{</xsl:text>
                  </xsl:if>
                  <!-- Wenn der Index schon überprüft wurde, aber der Text noch nicht abgeschlossen, erscheinen
              die indizierten Begriffe bunt-->
                  <xsl:choose>
                     <xsl:when test="@type = 'person'">
                        <xsl:text>\textcolor{blue}{</xsl:text>
                     </xsl:when>
                     <xsl:when test="@type = 'work'">
                        <xsl:text>\textcolor{green}{</xsl:text>
                     </xsl:when>
                     <xsl:when test="@type = 'org'">
                        <xsl:text>\textcolor{brown}{</xsl:text>
                     </xsl:when>
                     <xsl:when test="@type = 'place'">
                        <xsl:text>\textcolor{pink}{</xsl:text>
                     </xsl:when>
                     <xsl:when test="@type = 'event'">
                        <xsl:text>\textcolor{violet}{</xsl:text>
                     </xsl:when>
                  </xsl:choose>
                  <xsl:apply-templates/>
                  <xsl:text>}</xsl:text>
                  <!--<xsl:value-of
                     select="foo:indexName-Routine(@type, tokenize(@ref, ' ')[1], substring-after(@ref, ' '), $endung-index)"/>-->
                  <xsl:choose>
                     <xsl:when test="$im-text and not(@ref = '#2121' or @ref = '#50')">
                        <xsl:text>{</xsl:text>
                        <!--<xsl:value-of select="foo:lemma(.)"/>
                        <xsl:text>\Bendnote{</xsl:text>
                        <xsl:value-of
                           select="foo:indexName-EndnoteRoutine(@type, $verweis, $first, $rest)"/>
                        <xsl:text>}</xsl:text>-->
                        <xsl:text>}</xsl:text>
                        <xsl:text>\ledrightnote{</xsl:text>
                        <xsl:value-of
                           select="foo:marginpar-EndnoteRoutine(@type, $verweis, $first, $rest)"/>
                        <xsl:text>}</xsl:text>
                     </xsl:when>
                  </xsl:choose>
                  <xsl:if test="$emph">
                     <xsl:text>}</xsl:text>
                  </xsl:if>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:function name="foo:marginpar-EndnoteRoutine">
      <xsl:param name="typ" as="xs:string"/>
      <xsl:param name="verweis" as="xs:boolean"/>
      <xsl:param name="first" as="xs:string"/>
      <xsl:param name="rest" as="xs:string"/>
      <xsl:if test="$verweis">
         <xsl:text>→</xsl:text>
      </xsl:if>
      <xsl:choose>
         <xsl:when test="not(starts-with($first, '#pmb'))">
            <xsl:text>\textcolor{red}{KEY PROBLEM}</xsl:text>
         </xsl:when>
         <xsl:when test="$typ = 'person'">
            <xsl:choose>
               <xsl:when test="$first = '#pmb2121'">
                  <!-- Einträge  Schnitzler raus -->
               </xsl:when>
               <xsl:otherwise>
                  <xsl:variable name="namens-eintrag"
                     select="key('person-lookup', $first, $persons)/tei:persName[1]" as="node()"/>
                  <xsl:text>\textcolor{blue}{</xsl:text>
                  <xsl:choose>
                     <xsl:when test="$namens-eintrag/tei:surname and $namens-eintrag/tei:forename">
                        <xsl:value-of
                           select="concat($namens-eintrag/tei:forename, ' ', $namens-eintrag/tei:surname)"/>
                     </xsl:when>
                     <xsl:when test="$namens-eintrag/tei:surname or $namens-eintrag/tei:forename">
                        <xsl:value-of select="$namens-eintrag/tei:forename"/>
                        <xsl:value-of select="$namens-eintrag/tei:surname"/>
                     </xsl:when>
                     <xsl:otherwise>
                        <xsl:value-of select="$namens-eintrag"/>
                     </xsl:otherwise>
                  </xsl:choose>
                  <xsl:text>}</xsl:text>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:when>
         <xsl:when test="$typ = 'work'">
            <xsl:text>\textcolor{green}{</xsl:text>
            <xsl:variable name="eintrag" select="key('work-lookup', $first, $works)/tei:title[1]"
               as="xs:string"/>
            <xsl:choose>
               <xsl:when test="$eintrag = ''">
                  <xsl:text>XXXX</xsl:text>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:analyze-string select="$eintrag" regex="&amp;">
                     <xsl:matching-substring>
                        <xsl:text>{\kaufmannsund}</xsl:text>
                     </xsl:matching-substring>
                     <xsl:non-matching-substring>
                        <xsl:value-of select="."/>
                     </xsl:non-matching-substring>
                  </xsl:analyze-string>
               </xsl:otherwise>
            </xsl:choose>
            <xsl:text>}</xsl:text>
         </xsl:when>
         <xsl:when test="$typ = 'org'">
            <xsl:text>\textcolor{brown}{</xsl:text>
            <xsl:variable name="eintrag" select="key('org-lookup', $first, $orgs)/tei:orgName[1]"
               as="xs:string"/>
            <xsl:choose>
               <xsl:when test="$eintrag = ''">
                  <xsl:text>XXXX</xsl:text>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:analyze-string select="$eintrag" regex="&amp;">
                     <xsl:matching-substring>
                        <xsl:text>{\kaufmannsund}</xsl:text>
                     </xsl:matching-substring>
                     <xsl:non-matching-substring>
                        <xsl:value-of select="."/>
                     </xsl:non-matching-substring>
                  </xsl:analyze-string>
               </xsl:otherwise>
            </xsl:choose>
            <xsl:text>}</xsl:text>
         </xsl:when>
         <xsl:when test="$typ = 'place'">
            <xsl:text>\textcolor{pink}{</xsl:text>
            <xsl:variable name="eintrag" select="key('place-lookup', $first, $places)/tei:placeName[1]"
               as="xs:string"/>
            <xsl:choose>
               <xsl:when test="$eintrag = ''">
                  <xsl:text>XXXX</xsl:text>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:analyze-string select="$eintrag" regex="&amp;">
                     <xsl:matching-substring>
                        <xsl:text>{\kaufmannsund}</xsl:text>
                     </xsl:matching-substring>
                     <xsl:non-matching-substring>
                        <xsl:value-of select="."/>
                     </xsl:non-matching-substring>
                  </xsl:analyze-string>
               </xsl:otherwise>
            </xsl:choose>
            <xsl:text>}</xsl:text>
         </xsl:when>
      </xsl:choose>
      <xsl:if test="$rest != ''">
         <xsl:if test="$first != '#pmb2121'">
            <xsl:text>{\newline}</xsl:text>
         </xsl:if>
         <xsl:value-of
            select="foo:marginpar-EndnoteRoutine($typ, $verweis, tokenize($rest, ' ')[1], substring-after($rest, ' '))"
         />
      </xsl:if>
   </xsl:function>
   
 
</xsl:stylesheet>
