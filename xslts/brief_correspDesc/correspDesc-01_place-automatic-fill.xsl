<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:foo="whatever" version="3.0">
    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:output method="xml" indent="yes"/>
    <xsl:param name="places"
        select="document('https://raw.githubusercontent.com/arthur-schnitzler/schnitzler-orte/refs/heads/main/editions/schnitzler_places.xml')"/>
    <!-- Wiener Schnitzler in der verschachtelten Fassung (Ort > Hotel usw.) -->
    <xsl:param name="nested"
        select="document('https://raw.githubusercontent.com/wiener-moderne-verein/wienerschnitzler-data/refs/heads/data/data/editions/xml/wienerschnitzler_complete_nested.xml')"/>
    <!-- Schnitzlers Wohnadressen (JSON aus meta/wohnadressen_aus_relations.py), relativ zu diesem XSLT -->
    <xsl:param name="wohnadressen"
        select="json-doc(resolve-uri('../../meta/wohnadressen.json', static-base-uri()))"/>
    <xsl:variable name="schnitzler-wohnungen" as="map(*)*"
        select="$wohnadressen?*[?personRef = '#pmb2121']"/>
    <xsl:key name="place-lookup" match="tei:event" use="@when"/>
    <!-- Dieses XSLT macht folgendes:

        - es ergänzt den jeweiligen Aufenthaltsort Schnitzlers zu correspAction, wenn das für einen fixen Tag
        oder einen Zeitraum möglich ist (Variante 1) oder in einem Fenster von 5 Tagen nachdem der Brief
        geschickt wurde (Variante 2).

    -->
    <!-- Variante 1: Datum vorhanden. Maßgeblich ist, wo sich Schnitzler an dem Tag (bzw. an allen
    Tagen des Zeitraums) laut Wiener Schnitzler (verschachtelte Fassung) aufhielt:

    1) In Wien: die zu dem Zeitpunkt aktuelle Wohnadresse (meta/wohnadressen.json). Andere Orte
       desselben Tages (Ausflüge) sind dann egal. Gibt es keine (eindeutige) Wohnadresse, bleibt es
       bei Wien.
    2) Nicht in Wien, Zeitraum (notBefore/notAfter bzw. from/to) über mehrere Tage: alle Orte, die
       an allen Tagen des Zeitraums gemeinsam vorkommen, als jeweils eigenes placeName.
    3) Nicht in Wien, ein einzelner Tag (@when): alle Aufenthaltsorte dieses Tages, und zwar die
       jeweils tiefsten PMB-referenzierten Stellen der Verschachtelung (Ort > Hotel, Berg ...).

    Hat das date ein gültiges @when, gilt es als einzelner Tag, auch wenn zusätzlich
    notBefore/notAfter angegeben sind. Fehlt für einen Tag des Zeitraums ein Eintrag, wird nichts
    ergänzt. -->
    <xsl:template
        match="tei:correspAction[tei:persName[@ref = 'https://d-nb.info/gnd/118609807' or @ref = '#pmb2121'] and not(tei:placeName) and tei:date]">
        <xsl:variable name="tage" select="foo:tage(tei:date[1])" as="xs:date*"/>
        <xsl:variable name="events" as="element(tei:event)*"
            select="$tage ! (key('place-lookup', string(.), $nested))[1]"/>
        <xsl:variable name="vollstaendig" select="exists($tage) and count($events) = count($tage)"
            as="xs:boolean"/>
        <!-- Wien gilt, wenn er an allen Tagen (auch) in Wien ist -->
        <xsl:variable name="in-wien" as="xs:boolean"
            select="$vollstaendig and (every $e in $events satisfies $e/tei:listPlace/tei:place/@corresp = '#pmb50')"/>
        <!-- Fall 1: Wohnadresse, nur wenn sie an allen Tagen dieselbe ist -->
        <xsl:variable name="wohnung" as="map(*)?">
            <xsl:if
                test="$in-wien and (every $t in $tage satisfies exists(foo:wohnung($t)))">
                <xsl:variable name="erste" select="foo:wohnung($tage[1])"/>
                <xsl:if
                    test="every $t in $tage satisfies foo:wohnung($t)?placeRef = $erste?placeRef">
                    <xsl:sequence select="$erste"/>
                </xsl:if>
            </xsl:if>
        </xsl:variable>
        <!-- Fall 2 und 3: die Orte außerhalb Wiens. Für einen einzelnen Tag sind das alle Orte des
        Tages, für einen Zeitraum die, die an allen Tagen vorkommen. Davon nur die tiefsten. -->
        <xsl:variable name="reiseorte" as="element(tei:place)*">
            <xsl:if test="$vollstaendig and not($in-wien)">
                <xsl:variable name="kandidaten" as="element(tei:place)*"
                    select="$events[1]/tei:listPlace/tei:place[@corresp != '#pmb50']/descendant-or-self::tei:place[matches(@corresp, '^#pmb\d+$')]"/>
                <xsl:variable name="gemeinsam" as="element(tei:place)*"
                    select="$kandidaten[every $e in $events[position() gt 1] satisfies @corresp = $e/tei:listPlace/tei:place[@corresp != '#pmb50']/descendant-or-self::tei:place/@corresp]"/>
                <xsl:sequence select="$gemeinsam[not(descendant::tei:place intersect $gemeinsam)]"/>
            </xsl:if>
        </xsl:variable>
        <xsl:variable name="cmif" select="exists(ancestor::tei:profileDesc/tei:correspDesc[2])"
            as="xs:boolean"/>
        <xsl:element name="correspAction">
            <xsl:attribute name="type">
                <xsl:value-of select="@type"/>
            </xsl:attribute>
            <xsl:copy-of select="*"/>
            <xsl:choose>
                <!-- ungenaues oder fehlendes Datum, oder Lücken in den Daten: Ort nicht zu bestimmen -->
                <xsl:when test="not($vollstaendig)"/>
                <xsl:when test="$in-wien">
                    <xsl:choose>
                        <!-- CMIF-Dateien arbeiten mit geonames-Werten, die es für Wohnadressen nicht gibt -->
                        <xsl:when test="exists($wohnung) and not($cmif)">
                            <xsl:call-template name="ortsangabe">
                                <xsl:with-param name="ref" select="$wohnung?placeRef"/>
                                <xsl:with-param name="name" select="string($wohnung?placeName)"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="ortsangabe">
                                <xsl:with-param name="ref"
                                    select="if ($cmif) then 'https://sws.geonames.org/2761369/' else '#pmb50'"/>
                                <xsl:with-param name="name" select="'Wien'"/>
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:for-each-group select="$reiseorte" group-by="@corresp">
                        <xsl:call-template name="ortsangabe">
                            <xsl:with-param name="ref" select="current-grouping-key()"/>
                            <xsl:with-param name="name"
                                select="normalize-space(current-group()[1]/tei:placeName[1])"/>
                        </xsl:call-template>
                    </xsl:for-each-group>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>
    <xsl:template name="ortsangabe">
        <xsl:param name="ref" as="xs:string"/>
        <xsl:param name="name" as="xs:string"/>
        <xsl:element name="placeName" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:attribute name="evidence">
                <xsl:text>conjecture</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="ref" select="$ref"/>
            <xsl:value-of select="$name"/>
        </xsl:element>
    </xsl:template>
    <!-- Alle Tage, die ein date abdeckt: bei gültigem @when genau dieser, sonst von
    notBefore/from bis notAfter/to (einschließlich). Mit nur einer Grenze: keine Tage. -->
    <xsl:function name="foo:tage" as="xs:date*">
        <xsl:param name="date" as="element()"/>
        <xsl:variable name="when" select="$date/@when[. castable as xs:date]"/>
        <xsl:variable name="von"
            select="($date/@notBefore[. castable as xs:date], $date/@from[. castable as xs:date])[1]"/>
        <xsl:variable name="bis"
            select="($date/@notAfter[. castable as xs:date], $date/@to[. castable as xs:date])[1]"/>
        <xsl:choose>
            <xsl:when test="$when">
                <xsl:sequence select="xs:date($when)"/>
            </xsl:when>
            <xsl:when test="$von and $bis and xs:date($von) le xs:date($bis)">
                <xsl:sequence
                    select="for $i in 0 to xs:integer((xs:date($bis) - xs:date($von)) div xs:dayTimeDuration('P1D')) return xs:date($von) + xs:dayTimeDuration('P1D') * $i"
                />
            </xsl:when>
        </xsl:choose>
    </xsl:function>
    <!-- Schnitzlers Wohnadresse an einem Tag. Überschneiden sich mehrere Einträge, gilt der mit dem
    spätesten Beginn, bei Gleichstand der letzte in der Datei. Keine Wohnadresse: leer. -->
    <xsl:function name="foo:wohnung" as="map(*)?">
        <xsl:param name="tag" as="xs:date"/>
        <xsl:variable name="treffer" as="map(*)*"
            select="$schnitzler-wohnungen[(empty(?start) or xs:date(?start) le $tag) and (empty(?end) or $tag le xs:date(?end))]"/>
        <xsl:variable name="beginn" as="xs:date*"
            select="$treffer ! (if (empty(?start)) then xs:date('0001-01-01') else xs:date(?start))"/>
        <xsl:sequence select="$treffer[position() = index-of($beginn, max($beginn))[last()]]"/>
    </xsl:function>
    <!-- Variante 2: von Schnitzler, aber ohne datum: also ein Zeitraum von 5 Tagen ab Absendedatum. Das 
    Empfangsdatum wird als cert="low" vorgeschlagen, wenn es ein Ort gibt und mit notBefore/notAfter auf
    dieses Zeitfenster gesetzt-->
    <xsl:template
        match="tei:correspAction[tei:persName[@ref = 'https://d-nb.info/gnd/118609807' or @ref = '#pmb2121'] and not(tei:placeName) and not(tei:date)]">
        <xsl:variable name="sendedatum" as="xs:date?">
            <xsl:variable name="treffer"
                select="parent::tei:correspDesc/tei:correspAction[@type = 'sent']/tei:date/@when"/>
            <xsl:choose>
                <xsl:when test="xs:date($treffer) = $treffer">
                    <xsl:value-of select="$treffer"/>
                </xsl:when>
                <xsl:otherwise/>
            </xsl:choose>
        </xsl:variable>
        <xsl:element name="correspAction">
            <xsl:attribute name="type">
                <xsl:value-of select="@type"/>
            </xsl:attribute>
            <xsl:copy-of select="tei:persName"/>
            <xsl:choose>
                <xsl:when test="empty($sendedatum)"/>
                <!-- wenn nur ungenaues sendedatum ist der erhaltsort nicht zu bestimmen -->
                <xsl:when test="key('place-lookup', string($sendedatum), $places)//tei:listPlace[1]">
                    <xsl:variable name="eintrag"
                        select="key('place-lookup', string($sendedatum), $places)//tei:listPlace[1]"
                        as="node()"/>
                    <xsl:variable name="eintrag1"
                        select="key('place-lookup', string($sendedatum + xs:dayTimeDuration('P1D')), $places)//tei:listPlace[1]"
                        as="node()"/>
                    <xsl:variable name="eintrag2"
                        select="key('place-lookup', string($sendedatum + xs:dayTimeDuration('P2D')), $places)//tei:listPlace[1]"
                        as="node()"/>
                    <xsl:variable name="eintrag3"
                        select="key('place-lookup', string($sendedatum + xs:dayTimeDuration('P3D')), $places)//tei:listPlace[1]"
                        as="node()"/>
                    <xsl:variable name="eintrag4"
                        select="key('place-lookup', string($sendedatum + xs:dayTimeDuration('P4D')), $places)//tei:listPlace[1]"
                        as="node()"/>
                    <xsl:for-each
                        select="$eintrag/tei:place[tei:idno[@type = 'geonames'] != '' and tei:idno[@type = 'geonames']]/tei:idno[@type = 'pmb']">
                        <xsl:if
                            test=". = $eintrag1/tei:place/tei:idno[@type = 'pmb'] and . = $eintrag2/tei:place/tei:idno[@type = 'pmb'] and . = $eintrag3/tei:place/tei:idno[@type = 'pmb'] and . = $eintrag4/tei:place/tei:idno[@type = 'pmb']">
                            <xsl:variable name="aktuell" select="." as="xs:string"/>
                            <xsl:element name="placeName" namespace="http://www.tei-c.org/ns/1.0">
                                <xsl:attribute name="evidence">
                                    <xsl:text>conjecture</xsl:text>
                                </xsl:attribute>
                                <xsl:attribute name="ref">
                                    <xsl:choose>
                                        <!-- sind's mehr als ein correspDesc, ist es eine CMIF-Datei, also geonames-Werte -->
                                        <xsl:when
                                            test="ancestor::tei:profileDesc/tei:correspDesc[2]">
                                            <xsl:value-of
                                                select="$eintrag/tei:place[tei:idno[@type = 'pmb'] = $aktuell]/tei:idno[@type = 'geonames']"
                                            />
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:variable name="pmb-wert">
                                                <xsl:analyze-string
                                                  select="$eintrag/tei:place/tei:idno[@type = 'pmb' and . = $aktuell][1]"
                                                  regex="/(\d+)/">
                                                  <xsl:matching-substring>
                                                  <xsl:value-of select="regex-group(1)"/>
                                                  </xsl:matching-substring>
                                                </xsl:analyze-string>
                                            </xsl:variable>
                                            <xsl:value-of select="concat('#pmb', $pmb-wert)"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:attribute>
                                <xsl:if
                                    test="$eintrag/tei:place[tei:idno = $aktuell]/tei:placeName != 'Wien'">
                                    <xsl:attribute name="check"/>
                                </xsl:if>
                                <xsl:value-of
                                    select="$eintrag/tei:place[tei:idno = $aktuell]/tei:placeName"/>
                            </xsl:element>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
            </xsl:choose>
        </xsl:element>
    </xsl:template>
    <!-- Das hier holt die Namensform des Ortsnamens der PMB -->
    <xsl:template match="tei:correspAction/tei:placeName">
        <xsl:element name="placeName" namespace="http://www.tei-c.org/ns/1.0"
            inherit-namespaces="true">
            <xsl:copy-of select="@ref | @evidence | @cert"/>
            <xsl:variable name="nummer" select="replace(replace(@ref, 'pmb', ''), '#', '')"/>
            <xsl:choose>
                <xsl:when test="$nummer = '50'">
                    <xsl:text>Wien</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:variable name="eintrag"
                        select="fn:escape-html-uri(concat('https://pmb.acdh.oeaw.ac.at/apis/tei/place/', $nummer))"
                        as="xs:string"/>
                    <xsl:choose>
                        <xsl:when test="doc-available($eintrag)">
                            <xsl:value-of select="document($eintrag)/place/placeName[1]"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:element name="error" namespace="http://www.tei-c.org/ns/1.0">
                                <xsl:attribute name="type">
                                    <xsl:text>placeName-nicht-bezogen</xsl:text>
                                </xsl:attribute>
                                <xsl:value-of select="$nummer"/>
                            </xsl:element>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
