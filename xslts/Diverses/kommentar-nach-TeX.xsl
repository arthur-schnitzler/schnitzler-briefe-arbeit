<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions"
   xmlns:foo="whatever" xmlns:tei="http://www.tei-c.org/ns/1.0" version="3.0">
   <xsl:output method="text"/>
   <xsl:strip-space elements="*"/>
   
   <xsl:template match="*:root">
      <xsl:text>\input{latex-korrekturansicht-vorspann}</xsl:text>
      <xsl:for-each select="*:TEI">
         <xsl:sort select="descendant::*:correspDesc/*:correspAction[1]/*:date/@*[name()='when' or name()='from' or name()='notBefore']"></xsl:sort>
         <xsl:text>\section{</xsl:text>
         <xsl:value-of select="@*:id"/>
         <xsl:text> </xsl:text>
         <xsl:value-of select="descendant::*:titleStmt/*:title[@level='a']"/>
         <xsl:text>}</xsl:text>
         <xsl:text>&#10;</xsl:text>
         <xsl:if test="descendant::*:body//*:note[(@type='commentary' or @type='textConst')][1] and descendant::*:body//*:note[(@type='commentary' or @type='textConst') and not(child::*:ref[1] and not(child::*[2]) and normalize-space(.)='')]">
            <xsl:text>\begin{description}[nosep]</xsl:text>
         <xsl:apply-templates select="descendant::*:body//*:note[@type='commentary' or @type='textConst']"/>
            <xsl:text>\end{description}</xsl:text>
         </xsl:if>
      </xsl:for-each>
      <xsl:text>\end{document}</xsl:text>
      
   </xsl:template>
   
   
   
   <!-- anchors in Fussnoten, sehr seltener Fall-->
   <xsl:template
      match="*:anchor[(@type = 'textConst' or @type = 'commentary') and ancestor::*:note[@type = 'footnote']]">
      <xsl:variable name="xmlid" select="concat(@id, 'h')"/>
      <xsl:apply-templates/>
      <xsl:text>\toendnotes[C]{\begin{minipage}[t]{4em}{\makebox[3.6em][r]{\tiny{Fußnote}}}\end{minipage}\begin{minipage}[t]{\dimexpr\linewidth-4em}\textit{</xsl:text>
      <xsl:for-each-group select="following-sibling::node()"
         group-ending-with="*:note[@type = 'commentary']">
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
      match="*:anchor[(@type = 'textConst' or @type = 'commentary') and not(ancestor::note[@type = 'footnote'])]">
      <xsl:variable name="typ-i-typ" select="@type"/>
      <xsl:variable name="lemmatext" as="xs:string">
         <xsl:for-each-group select="following-sibling::node()"
            group-ending-with="*:note[@type = $typ-i-typ]">
            <xsl:if test="position() eq 1">
               <xsl:apply-templates select="current-group()[position() != last()]" mode="lemma"/>
            </xsl:if>
         </xsl:for-each-group>
      </xsl:variable>
      <xsl:apply-templates/>
   </xsl:template>
   <xsl:template
      match="*:note[(@type = 'textConst' or @type = 'commentary') and not(ancestor::*:note[@type = 'footnote'])]"
      mode="lemma"/>
   <xsl:template match="*:subst/*:del" mode="lemma"/><!-- das verhindert die Wiedergabe des gelöschten Teils von subst in einem Lemma -->
   <xsl:template match="*:space[@unit = 'chars' and @quantity = '1']" mode="lemma">
      <xsl:text> </xsl:text>
   </xsl:template>
   <xsl:template match="space[@unit = 'chars' and @quantity = '1']">
      <xsl:text> </xsl:text>
   </xsl:template>
   <xsl:template
      match="*:note[(@type = 'textConst' or @type = 'commentary') and not(ancestor::*:note[@type = 'footnote'])]">
      <xsl:choose>
         <xsl:when test="child::*:ref[1] and not(child::*[2]) and normalize-space(.)=''"/> <!-- das sollte reine Verweise rauskürzen -->
         <xsl:otherwise>
      <!-- Der Teil hier bildet das Lemma und kürzt es -->
      <xsl:variable name="lemma-start" as="xs:string"
         select="substring(@id, 1, string-length(@id) - 1)"/>
      <xsl:variable name="lemma-end" as="xs:string" select="@id"/>
      <xsl:variable name="lemmaganz">
         <xsl:for-each-group
            select="ancestor::*/*:anchor[@id = $lemma-start]/following-sibling::node()"
            group-ending-with="*:note[@id = $lemma-end]">
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
      <xsl:text>\item[</xsl:text>
      <xsl:choose>
         <xsl:when test="Lemma">
            <xsl:value-of select="Lemma"/>
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
      <xsl:text>]&#10;</xsl:text>
      <xsl:apply-templates select="node() except Lemma"/>
      <xsl:text>&#10;</xsl:text>
         </xsl:otherwise></xsl:choose>
   </xsl:template>
   
   <xsl:template match="ref[@type = 'pointer']">
      <!-- Pointer funktionieren so, dass sie, wenn sie auf v enden, auf einen Bereich zeigen, sonst
      wird einfach zweimal der selbe Punkt gesetzt-->
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
   <xsl:template match="ref[@type = 'schnitzler-tagebuch']">
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
         <xsl:text>A.&#8239;S.: \emph{Tagebuch}, </xsl:text>
      </xsl:if>
      <xsl:value-of select="
         format-date(@target,
         '[D1].&#8239;[M1].&#8239;[Y0001]')"/>
   </xsl:template>
   <xsl:template match="ref[@type = 'schnitzler-lektueren']">
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
         <xsl:when test="@target='Deutschsprachige-Literatur'">
            <xsl:text>deutschsprachige Literatur</xsl:text>
         </xsl:when>
         <xsl:when test="@target='Polen-Czechen'">
            <xsl:text>Polen, Czechen</xsl:text>
         </xsl:when>
         <xsl:when test="@target='Ungarn-etc.'">
            <xsl:text>Ungarn etc.</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="replace(@target, '.html', '')"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:template match="ref[@type = 'schnitzler-bahr']">
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
         <xsl:text>Bahr/Schnitzler, </xsl:text>
      </xsl:if>
      <xsl:value-of select="replace(@target, '.html', '')"/>
   </xsl:template>
   <xsl:template match="ref[@type = 'schnitzler-interviews']">
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
      <xsl:value-of select="normalize-space(document(concat('https://raw.githubusercontent.com/arthur-schnitzler/schnitzler-interviews-static/main/data/editions/', replace(@target, '.html', ''), '.xml'))/descendant::tei:titleStmt/tei:title[@level='a'])"/>
   </xsl:template>
   <xsl:template match="ref[@type = 'url']">
      <xsl:text>\uline{\url{</xsl:text>
      <xsl:value-of select="(@target)"/>
      <xsl:text>}}</xsl:text>
   </xsl:template>
   <xsl:template match="ref[@type = 'schnitzler-briefe']">
      <xsl:variable name="currenttarget" select="@target" as="xs:string"/>
      <xsl:choose>
         <xsl:when test="@target = ''">
            <xsl:text>{XXXX ref}</xsl:text>
         </xsl:when>
         <xsl:when test="@subtype = 'date-only'">
            <xsl:value-of
               select="ancestor::*:root/descendant::*:TEI[@id=$currenttarget or @xml:id=$currenttarget]/descendant::*:correspDesc/*:correspAction[@type = 'sent']/*:date/text()"
            />
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
            <xsl:choose>
               <xsl:when test="ancestor::*:root/descendant::*:TEI[@id=$currenttarget or @xml:id=$currenttarget]//*:titleStmt/*:title[@level = 'a']">
                  <xsl:value-of
                     select="ancestor::*:root/descendant::*:TEI[@id=$currenttarget or @xml:id=$currenttarget]//*:titleStmt/*:title[@level = 'a']"
                     > </xsl:value-of>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:text>XXXX Auszeichnungsfehler</xsl:text>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   
   
   
   <xsl:template match="c[@rendition = '#kaufmannsund']">
      <xsl:text>{\kaufmannsund}</xsl:text>
   </xsl:template>
   <xsl:template match="c[@rendition = '#tilde']">
      <xsl:text>{\char`~}</xsl:text>
   </xsl:template>
   <xsl:template match="c[@rendition = '#geschwungene-klammer-auf']">
      <xsl:text>{\{}</xsl:text>
   </xsl:template>
   <xsl:template match="c[@rendition = '#geschwungene-klammer-zu']">
      <xsl:text>{\}}</xsl:text>
   </xsl:template>
   <!-- Geminationsstriche -->
   <xsl:template match="c[@rendition = '#gemination-m']">
      <xsl:text>{\geminationm}</xsl:text>
   </xsl:template>
   <xsl:template match="c[@rendition = '#gemination-n']">
      <xsl:text>{\geminationn}</xsl:text>
   </xsl:template>
   <xsl:template match="c[@rendition = '#gemination-m']" mode="lemma">
      <xsl:text>mm</xsl:text>
   </xsl:template>
   <xsl:template match="c[@rendition = '#gemination-n']" mode="lemma">
      <xsl:text>nn</xsl:text>
   </xsl:template>
   <!-- Prozentzeichen % -->
   <xsl:template match="c[@rendition = '#prozent']">
      <xsl:text>{\%}</xsl:text>
   </xsl:template>
   <!-- Dollarzeichen $ -->
   <xsl:template match="c[@rendition = '#dollar']">
      <xsl:text>{\$}</xsl:text>
   </xsl:template>
   <!-- Unterstreichung -->
   <xsl:template match="hi[@rend = 'underline']">
      <xsl:choose>
         <xsl:when
            test="parent::hi[@rend = 'superscript'] | parent::hi[parent::signed and @rend = 'overline'] | ancestor::addrLine">
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
   <xsl:template match="hi[@rend = 'overline']">
      <xsl:choose>
         <xsl:when test="parent::signed | ancestor::addressLine">
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
   <xsl:template match="supplied[not(parent::damage)]">
      <xsl:text disable-output-escaping="yes">{[}</xsl:text>
      <xsl:apply-templates/>
      <xsl:text disable-output-escaping="yes">{]}</xsl:text>
   </xsl:template>
   <!-- Unleserlich, unsicher Entziffertes -->
   <xsl:template match="unclear">
      <xsl:text>\textcolor{gray}{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
   </xsl:template>
   <!-- Durch Zerstörung unleserlich. Text ist stets Herausgebereingriff -->
   <xsl:template match="damage">
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
   <xsl:template match="gap[@unit = 'chars' and @reason = 'illegible']">
      <xsl:value-of select="foo:gapigap(@quantity)"/>
   </xsl:template>
   <xsl:template match="gap[@unit = 'lines' and @reason = 'illegible']">
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
   <xsl:template match="gap[@reason = 'outOfScope']">
      <xsl:text>{[}\ldots{]}</xsl:text>
   </xsl:template>
   <xsl:template match="gap[@reason = 'gabelsberger']">
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
   <xsl:template match="c[@rendition = '#dots']">
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
   <xsl:template match="*:rs[(@type='work' or @type='org') and not(@subtype='implied')]|*:title[not(@subtype='implied')]">
      <xsl:text>\textit{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
   </xsl:template>
   <xsl:template match="*:quote">
      <xsl:choose>
      <xsl:when test="*:p">
         <xsl:for-each select="*:p[not(position() = last())]">
            <xsl:apply-templates/>
            <xsl:text>{ / }</xsl:text>
         </xsl:for-each>
         <xsl:apply-templates select="*:p[(position() = last())]"/>
      </xsl:when>
      <xsl:otherwise>
         <xsl:apply-templates/>
      </xsl:otherwise>
   </xsl:choose></xsl:template>
</xsl:stylesheet>