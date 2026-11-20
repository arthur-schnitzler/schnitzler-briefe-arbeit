<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:mam="martinfunktion" version="3.0" exclude-result-prefixes="#all">
    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:output method="xml" indent="yes" encoding="utf-8" omit-xml-declaration="false"/>
    <!--
        Wird auf das Ergebnis von 05 (indices/schnitzler-briefe-cmif_precise-location.xml)
        angewandt und erzeugt indices/schnitzler-briefe-cmif.xml.

        In den Daten stehen in correspAction/placeName inzwischen meist die präzisen Orte
        (Wohnadresse, Hotel, Postamt, Ordination …). Für Aggregatoren wie correspSearch
        braucht es dagegen die geographische Ortschaft (Stadt, Dorf). Dieses XSLT ersetzt
        deshalb in allen correspAction (sent, received, transmitted …) den präzisen Ort durch
        die Ortschaft, in der er liegt (@ref und Text). Alles andere bleibt unverändert,
        auch die mentionsPlace-Verweise in note.

        Ermittlung der Ortschaft über location[@type='located_in_place'] in
        indices/listplace.xml; Orte, die dort fehlen, werden über die PMB-API nachgeladen
        (Parameter pmb-api):
        1. Ist der Ort selbst schon eine Ortschaft, bleibt er stehen. Als Ortschaft gelten
           P.* (außer P.PPLX), A.BSO und A.ADM2 bis A.ADM5 – außer den Wiener
           Gemeindebezirken (pmb51–pmb73), die als Teil von Wien zählen – sowie Städte, die
           in der PMB als Verwaltungseinheit oder Land typisiert sind (Wien, Prag, Moskau,
           Istanbul, Singapur, Gibraltar).
        2. Ersetzt werden nur präzise Örtlichkeiten: Gebäude, Adressen, Straßen, Post- und
           Telegrafenämter, Bezirke und Ortsteile (K.*, S.*, R.*, P.PPLX, A.BSOX, A.BZK,
           A.VOO, Postamt …) sowie Orte ohne Typangabe. Von ihnen aus wird Ebene für Ebene
           aufgestiegen, bis eine Ortschaft gefunden ist; weiter geklettert wird nur über
           solche Unterorte, nicht über Regionen, Länder oder Naturräume. Bei mehreren
           Ortschaften auf derselben Ebene gewinnt die genaueste (die nicht selbst eine der
           anderen enthält), dann eine, die in der Edition vorkommt (listplace.xml).
           Beispiele: Zelinkagasse 11 → Wien, Hotel Edlacherhof → Edlach an der Rax,
           Hofmannsthal-Schlössl → Rodaun, 9/3 Post- und Telegraphenamt 72 → Wien.
        3. Ein Stadtteil, dessen Name den Namen des übergeordneten Orts enthält, steigt zu
           diesem auf: »16. arrondissement [Paris]« → Paris, »München-Schwabing« → München.
           Dörfer, die zu einer größeren Gemeinde gehören (Seis am Schlern, Lauffen …),
           bleiben dagegen eigene Orte.
        4. Landschaften, Gewässer, Berge, Regionen und Länder bleiben, wie sie sind. Findet
           sich zu einer präzisen Örtlichkeit keine Ortschaft (Gebäude ohne Ortsangabe in
           der PMB, Berghotel), bleibt sie ebenfalls stehen und wird per xsl:message
           gemeldet, damit die Angabe in der PMB ergänzt werden kann.
    -->
    <xsl:param name="listplace" select="document('../../indices/listplace.xml')"/>
    <!-- false(), um ohne Netz nur mit listplace.xml zu arbeiten -->
    <xsl:param name="pmb-api" as="xs:boolean" select="true()"/>
    <xsl:key name="place-match" match="tei:place" use="@xml:id"/>
    <xsl:variable name="wiener-bezirke" as="xs:string*"
        select="for $i in 51 to 73 return concat('pmb', $i)"/>
    <!-- Wien, Prag, Moskau, Istanbul, Singapur, Gibraltar -->
    <xsl:variable name="staedte-mit-verwaltungstyp" as="xs:string*"
        select="('pmb50', 'pmb652', 'pmb869', 'pmb966', 'pmb118677', 'pmb51646')"/>
    <!-- PMB-Typen ohne Geonames-Code, die innerhalb einer Ortschaft liegen -->
    <xsl:variable name="unterorte-ohne-code" as="xs:string*"
        select="('Postamt', 'Telegrafenamt', 'Postrayon', 'Ordination', 'Wohnung', 'Haltestelle',
        'Brunnen', 'Einkaufspassage', 'Denkmal', 'Synagoge', 'Ausstellungsgelände', 'Gefängnis',
        'Konzerthaus', 'Verlag', 'Turm', 'Stadtmauer', 'Flughafen', 'Bahn', 'Kanal')"/>
    <!-- Ortseintrag: zuerst listplace.xml (TEI-Namensraum), sonst PMB-API (ohne Namensraum),
        daher im Folgenden immer *:-Pfade -->
    <xsl:function name="mam:eintrag" as="element()?">
        <xsl:param name="id" as="xs:string"/>
        <xsl:variable name="lokal" select="key('place-match', $id, $listplace)[1]"/>
        <xsl:choose>
            <xsl:when test="exists($lokal)">
                <xsl:sequence select="$lokal"/>
            </xsl:when>
            <xsl:when test="$pmb-api">
                <xsl:variable name="url"
                    select="concat('https://pmb.acdh.oeaw.ac.at/apis/tei/place/', replace($id, '\D', ''))"/>
                <xsl:sequence select="if (doc-available($url)) then doc($url)/*:place[1] else ()"/>
            </xsl:when>
        </xsl:choose>
    </xsl:function>
    <xsl:function name="mam:im-korpus" as="xs:boolean">
        <xsl:param name="id" as="xs:string"/>
        <xsl:sequence select="exists(key('place-match', $id, $listplace))"/>
    </xsl:function>
    <xsl:function name="mam:name" as="xs:string">
        <xsl:param name="id" as="xs:string"/>
        <xsl:sequence select="normalize-space(string(mam:eintrag($id)/*:placeName[1]))"/>
    </xsl:function>
    <!-- "Wohngebäude (K.WHS)" -> "K.WHS", "A.ADM3" -> "A.ADM3", "Postamt" -> "Postamt" -->
    <xsl:function name="mam:typ" as="xs:string">
        <xsl:param name="id" as="xs:string"/>
        <xsl:variable name="t"
            select="normalize-space(string(mam:eintrag($id)/*:desc[@type = 'entity_type'][1]))"/>
        <xsl:sequence
            select="if (matches($t, '\([A-Z]+\.[A-Z0-9]+\)$')) then replace($t, '^.*\(([A-Z]+\.[A-Z0-9]+)\)$', '$1') else $t"
        />
    </xsl:function>
    <!-- 'ort' (Stadt, Dorf), 'unter' (liegt in einer Ortschaft), 'sonst' (Region, Land,
        Naturraum …), 'unbekannt' (ohne Typangabe oder weder in listplace.xml noch über die API) -->
    <xsl:function name="mam:klasse" as="xs:string">
        <xsl:param name="id" as="xs:string"/>
        <xsl:variable name="typ" select="mam:typ($id)"/>
        <xsl:choose>
            <xsl:when test="$id = $staedte-mit-verwaltungstyp">
                <xsl:sequence select="'ort'"/>
            </xsl:when>
            <xsl:when test="$id = $wiener-bezirke">
                <xsl:sequence select="'unter'"/>
            </xsl:when>
            <xsl:when test="empty(mam:eintrag($id)) or $typ = ''">
                <xsl:sequence select="'unbekannt'"/>
            </xsl:when>
            <xsl:when test="$typ = ('P.PPLX', 'A.BSOX', 'A.BZK', 'A.VOO')">
                <xsl:sequence select="'unter'"/>
            </xsl:when>
            <xsl:when test="starts-with($typ, 'P.') or $typ = 'A.BSO' or matches($typ, '^A\.ADM[2-5]$')">
                <xsl:sequence select="'ort'"/>
            </xsl:when>
            <xsl:when test="substring($typ, 1, 2) = ('K.', 'S.', 'R.') or $typ = $unterorte-ohne-code">
                <xsl:sequence select="'unter'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="'sonst'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <!-- Reihenfolge erhaltendes distinct-values -->
    <xsl:function name="mam:einmal" as="xs:string*">
        <xsl:param name="werte" as="xs:string*"/>
        <xsl:sequence
            select="for $i in 1 to count($werte) return $werte[$i][not(. = subsequence($werte, 1, $i - 1))]"/>
    </xsl:function>
    <!-- übergeordnete Orte (located_in_place), als pmb-IDs; Wiener Bezirke liegen in Wien -->
    <xsl:function name="mam:eltern" as="xs:string*">
        <xsl:param name="id" as="xs:string"/>
        <xsl:sequence
            select="
                if ($id = $wiener-bezirke) then 'pmb50'
                else mam:einmal(for $k in mam:eintrag($id)/*:location[@type = 'located_in_place']/*:placeName/@key
                    return concat('pmb', replace($k, '\D', '')))[not(. = ($id, 'pmb'))]"/>
    </xsl:function>
    <!-- alle Vorfahren; über Regionen, Länder u. Ä. wird nicht weiter aufgestiegen -->
    <xsl:function name="mam:vorfahren" as="xs:string*">
        <xsl:param name="offen" as="xs:string*"/>
        <xsl:param name="gesehen" as="xs:string*"/>
        <xsl:param name="tiefe" as="xs:integer"/>
        <xsl:variable name="neu" as="xs:string*"
            select="mam:einmal(for $x in $offen[mam:klasse(.) != 'sonst'] return mam:eltern($x))[not(. = $gesehen)]"/>
        <xsl:sequence
            select="if (empty($neu) or $tiefe ge 12) then $gesehen else mam:vorfahren($neu, ($gesehen, $neu), $tiefe + 1)"/>
    </xsl:function>
    <!-- Breitensuche nach der nächstgelegenen Ortschaft -->
    <xsl:function name="mam:naechste-ortschaft" as="xs:string?">
        <xsl:param name="ebene" as="xs:string*"/>
        <xsl:param name="gesehen" as="xs:string*"/>
        <xsl:param name="tiefe" as="xs:integer"/>
        <xsl:variable name="naechste" as="xs:string*"
            select="mam:einmal(for $x in $ebene return mam:eltern($x))[not(. = $gesehen)]"/>
        <xsl:variable name="orte" as="xs:string*" select="$naechste[mam:klasse(.) = 'ort']"/>
        <xsl:choose>
            <xsl:when test="exists($orte)">
                <xsl:variable name="genaueste" as="xs:string*"
                    select="$orte[not(some $o2 in $orte satisfies ($o2 != . and . = mam:vorfahren(mam:eltern($o2), mam:eltern($o2), 0)))]"/>
                <xsl:variable name="kandidaten" as="xs:string*"
                    select="if (exists($genaueste)) then $genaueste else $orte"/>
                <xsl:sequence
                    select="($kandidaten[mam:im-korpus(.)], $kandidaten[not(mam:im-korpus(.))])[1]"/>
            </xsl:when>
            <xsl:when test="$tiefe ge 8"/>
            <xsl:otherwise>
                <xsl:variable name="weiter" as="xs:string*"
                    select="$naechste[mam:klasse(.) = ('unter', 'unbekannt')]"/>
                <xsl:sequence
                    select="if (exists($weiter)) then mam:naechste-ortschaft($weiter, ($gesehen, $naechste), $tiefe + 1) else ()"
                />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <xsl:function name="mam:wortfolge" as="xs:string">
        <xsl:param name="s" as="xs:string"/>
        <xsl:sequence select="concat(' ', normalize-space(replace($s, '\W+', ' ')), ' ')"/>
    </xsl:function>
    <!-- Stadtteil, dessen Name den Namen des übergeordneten Orts enthält -> Oberort -->
    <xsl:function name="mam:stadtteil-aufsteigen" as="xs:string">
        <xsl:param name="ort" as="xs:string"/>
        <xsl:param name="schritte" as="xs:integer"/>
        <xsl:variable name="eigener-name" select="mam:wortfolge(mam:name($ort))"/>
        <xsl:variable name="hoeher" as="xs:string*"
            select="mam:eltern($ort)[mam:klasse(.) = 'ort' and mam:name(.) != '' and contains($eigener-name, mam:wortfolge(mam:name(.)))]"/>
        <xsl:sequence
            select="if (exists($hoeher) and $schritte lt 3) then mam:stadtteil-aufsteigen($hoeher[1], $schritte + 1) else $ort"
        />
    </xsl:function>
    <xsl:function name="mam:ortschaft" as="xs:string?">
        <xsl:param name="id" as="xs:string"/>
        <xsl:variable name="klasse" select="mam:klasse($id)"/>
        <xsl:variable name="ort" as="xs:string?"
            select="
                if ($klasse = 'ort') then $id
                else if ($klasse = ('unter', 'unbekannt')) then mam:naechste-ortschaft($id, $id, 1)
                else ()"/>
        <xsl:sequence select="if (exists($ort)) then mam:stadtteil-aufsteigen($ort, 0) else ()"/>
    </xsl:function>
    <xsl:variable name="ortschaft-von" as="map(xs:string, xs:string)">
        <xsl:map>
            <xsl:for-each
                select="distinct-values(//tei:correspAction/tei:placeName/@ref[matches(normalize-space(.), '^#?pmb\d+$')]/replace(normalize-space(.), '^#', ''))">
                <xsl:variable name="ortschaft" select="mam:ortschaft(.)"/>
                <xsl:if test="exists($ortschaft) and $ortschaft != .">
                    <xsl:map-entry key="." select="$ortschaft"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:map>
    </xsl:variable>
    <xsl:template match="/">
        <xsl:variable name="ohne-ortschaft" as="xs:string*"
            select="distinct-values(//tei:correspAction/tei:placeName/@ref/replace(normalize-space(.), '^#', ''))[mam:klasse(.) = ('unter', 'unbekannt') and empty(mam:ortschaft(.))]"/>
        <xsl:if test="exists($ohne-ortschaft)">
            <xsl:message select="concat('Keine Ortschaft gefunden, präziser Ort bleibt stehen (', count($ohne-ortschaft), '): ', string-join(for $id in $ohne-ortschaft return concat($id, ' ', mam:name($id)), '; '))"/>
        </xsl:if>
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:correspAction/tei:placeName[@ref]">
        <xsl:variable name="ortschaft" as="xs:string?"
            select="$ortschaft-von(replace(normalize-space(@ref), '^#', ''))"/>
        <xsl:choose>
            <xsl:when test="exists($ortschaft)">
                <xsl:copy>
                    <xsl:attribute name="ref" select="concat('#', $ortschaft)"/>
                    <xsl:copy-of select="@* except @ref"/>
                    <xsl:value-of select="mam:name($ortschaft)"/>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
