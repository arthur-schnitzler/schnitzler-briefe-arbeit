<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:mam="martinfunktion" version="3.0">
    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:output method="xml" indent="yes"/>
    <!-- Das holt die GND-Nummer aus der PMB -->
    <xsl:param name="listperson" select="document('../../indices/listperson.xml')"/>
    <xsl:key name="person-match" match="//tei:text[1]/tei:body[1]/tei:listPerson[1]/tei:person"
        use="@xml:id"/>
    <xsl:param name="listplace" select="document('../../indices/listplace.xml')"/>
    <xsl:key name="place-match" match="//tei:text[1]/tei:body[1]/tei:listPlace[1]/tei:place"
        use="@xml:id"/>

    <!--
        Laut correspSearch-Handbuch braucht es für Orte grundsätzlich die
        Geonames-Kennung der Feature-Class "P" (Stadt/Dorf), nicht "A"
        (Verwaltungseinheit) – sonst entstehen in Aggregatoren wie
        correspSearch Dubletten für dieselbe Stadt. Straßen sind ebenfalls
        keine eigenständigen Orte in diesem Sinn. Nur "besondere Orte" wie
        Gebäude, Schlösser, Seen etc. dürfen ihre eigene Kennung behalten.
        entity_type in listplace.xml kodiert das als "Klasse.Code"
        (z. B. "A.ADM3", "P.PPL", teils mit deutschem Label davor,
        z. B. "Besiedelter Ort (A.BSO)"). "A.BSO"/"A.BSOX" (Besiedelter
        Ort/Teil eines besiedelten Ortes) zählen dabei wie eine Stadt, nicht
        wie eine Verwaltungseinheit. Nur untergeordnete Verwaltungsgrenzen
        (ADM1-4: Bundesland bis Ortsteil) und Straßen (K.STR) gelten als
        "muss aufsteigen" – ein Staat (PCLI) ist, wenn er direkt referenziert
        wird, selbst schon das gewünschte Ziel (es gibt darüber keine
        "Stadt", zu der man sinnvoll aufsteigen könnte).
    -->
    <xsl:function name="mam:ist-verwaltungseinheit-oder-strasse" as="xs:boolean">
        <xsl:param name="eintrag" as="node()?"/>
        <xsl:sequence select="matches(mam:orts-code($eintrag), '^A\.ADM\d+$') or mam:orts-code($eintrag) = 'K.STR'"/>
    </xsl:function>

    <!-- Extrahiert aus entity_type den "Klasse.Code"-Teil, auch wenn ein deutsches Label davorsteht -->
    <xsl:function name="mam:orts-code" as="xs:string">
        <xsl:param name="eintrag" as="node()?"/>
        <xsl:variable name="typtext" select="string($eintrag/tei:desc[@type = 'entity_type'][1])"/>
        <xsl:sequence
            select="
                if (matches($typtext, '\([A-Z]+\.[A-Z0-9]+\)$'))
                then replace($typtext, '.*\(([A-Z]+\.[A-Z0-9]+)\)$', '$1')
                else $typtext"/>
    </xsl:function>

    <!--
        Rangfolge, um beim Aufsteigen unter mehreren eingetragenen
        übergeordneten Orten den räumlich nächstliegenden zu bevorzugen:
        location[@type='located_in_place'] listet oft nicht nur den
        unmittelbaren Container, sondern gleich mehrere Ebenen auf einmal
        (z. B. bei einem Bezirk sowohl die Stadt als auch das Land) – ohne
        Rang würde dann per Dokumentreihenfolge zufällig das Land statt der
        Stadt gewählt. Kleinere Zahl = spezifischer/bevorzugt.
    -->
    <xsl:function name="mam:orts-rang" as="xs:integer">
        <xsl:param name="id" as="xs:string"/>
        <xsl:param name="eintrag" as="node()?"/>
        <xsl:variable name="code" select="mam:orts-code($eintrag)"/>
        <xsl:choose>
            <xsl:when test="$id = 'pmb50'">
                <xsl:sequence select="1"/>
            </xsl:when>
            <xsl:when test="starts-with($code, 'P.') or $code = ('A.BSO', 'A.BSOX')">
                <xsl:sequence select="1"/>
            </xsl:when>
            <xsl:when test="$code = 'A.ADM4'">
                <xsl:sequence select="2"/>
            </xsl:when>
            <xsl:when test="$code = 'A.ADM3'">
                <xsl:sequence select="3"/>
            </xsl:when>
            <xsl:when test="$code = 'A.ADM2'">
                <xsl:sequence select="4"/>
            </xsl:when>
            <xsl:when test="$code = 'A.ADM1'">
                <xsl:sequence select="5"/>
            </xsl:when>
            <xsl:when test="$code = 'A.PCLI'">
                <xsl:sequence select="6"/>
            </xsl:when>
            <xsl:when test="$code = 'K.STR'">
                <xsl:sequence select="3"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="0"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!--
        Normdaten (Geonames > GND > Wikidata) für einen PMB-Ort, mit Aufstieg
        in der Orts-Hierarchie: Häuser, Straßen und Bezirke (auch pmb51 bis
        pmb73, die Wiener Gemeindebezirke) haben oft keine eigenen Normdaten
        – und selbst wenn eine Straße oder ein Bezirk eine eigene
        Geonames-Kennung hat, ist das die falsche Klasse (s. o.), es muss
        trotzdem zur nächsten Stadt/zum nächsten besonderen Ort aufgestiegen
        werden. In listplace.xml trägt jeder Ort seine übergeordneten Orte
        als location[@type='located_in_place']/placeName/@key ein (Haus ->
        Straße -> Bezirk -> Wien -> Österreich, je nachdem wie vollständig
        die PMB-Daten sind); der Reihe nach werden die dort eingetragenen
        übergeordneten Orte geprüft, rekursiv, bis eine Stadt/ein besonderer
        Ort mit Normdaten gefunden wird oder die Hierarchie erschöpft ist.
        Nur auf der obersten Ebene (tiefe = 0) werden notfalls doch die
        eigenen (ggf. administrativen) Normdaten des ursprünglich
        referenzierten Orts verwendet, damit nicht bei einer unvollständig
        verknüpften Hierarchie am Ende gar nichts übrig bleibt. $tiefe
        schützt außerdem vor Zyklen in den Daten.

        pmb50 (Wien) ist trotz administrativer Einordnung (A.ADM2) in der
        PMB fix auf die Stadt-Kennung (nicht die Verwaltungs-Kennung)
        gesetzt, da Wien selbst schon das gewünschte Ziel ist.
    -->
    <xsl:function name="mam:place-normdata" as="xs:string?">
        <xsl:param name="id" as="xs:string"/>
        <xsl:param name="tiefe" as="xs:integer"/>
        <xsl:variable name="eintrag" select="key('place-match', $id, $listplace)"/>
        <xsl:variable name="direkt" as="xs:string?">
            <xsl:choose>
                <xsl:when test="$id = 'pmb50'">
                    <xsl:sequence select="'https://sws.geonames.org/2761369/'"/>
                </xsl:when>
                <xsl:when test="$eintrag/tei:idno[@type = 'geonames' or @subtype = 'geonames'][1]">
                    <xsl:sequence
                        select="string($eintrag/tei:idno[@type = 'geonames' or @subtype = 'geonames'][1])"/>
                </xsl:when>
                <xsl:when test="$eintrag/tei:idno[@type = 'gnd' or @subtype = 'gnd'][1]">
                    <xsl:sequence select="string($eintrag/tei:idno[@type = 'gnd' or @subtype = 'gnd'][1])"/>
                </xsl:when>
                <xsl:when test="$eintrag/tei:idno[@type = 'wikidata' or @subtype = 'wikidata'][1]">
                    <xsl:sequence
                        select="string($eintrag/tei:idno[@type = 'wikidata' or @subtype = 'wikidata'][1])"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="verwaltung-oder-strasse" as="xs:boolean"
            select="$id != 'pmb50' and mam:ist-verwaltungseinheit-oder-strasse($eintrag)"/>
        <xsl:variable name="geklettert" as="xs:string?">
            <xsl:if test="$tiefe lt 6">
                <xsl:variable name="eltern" as="xs:string*"
                    select="$eintrag/tei:location[@type = 'located_in_place']/tei:placeName/@key"/>
                <xsl:variable name="eltern-sortiert" as="xs:string*">
                    <xsl:perform-sort select="$eltern">
                        <xsl:sort select="mam:orts-rang(., key('place-match', ., $listplace))"
                            data-type="number"/>
                    </xsl:perform-sort>
                </xsl:variable>
                <xsl:sequence
                    select="(for $eltern-id in $eltern-sortiert return mam:place-normdata($eltern-id, $tiefe + 1))[1]"/>
            </xsl:if>
        </xsl:variable>
        <xsl:choose>
            <!-- Stadt/Dorf oder besonderer Ort mit eigenen Normdaten: verwenden -->
            <xsl:when test="exists($direkt) and not($verwaltung-oder-strasse)">
                <xsl:sequence select="$direkt"/>
            </xsl:when>
            <!-- sonst (Verwaltungseinheit/Straße, oder gar keine eigenen Daten): aufsteigen -->
            <xsl:when test="exists($geklettert)">
                <xsl:sequence select="$geklettert"/>
            </xsl:when>
            <!-- nur ganz oben, als letzter Ausweg: doch die eigenen Daten -->
            <xsl:when test="$tiefe = 0">
                <xsl:sequence select="$direkt"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <xsl:template
        match="tei:persName/@ref[contains(., 'pmb')] | tei:rs[@type = 'person']/@ref[contains(., 'pmb')]">
        <xsl:variable name="nummeri"
            select="replace(replace(replace(., '#', ''), 'pmb', ''), '/', '')"/>
        <!-- Variante, um die Daten aus der PMB zu holen: -->
        <xsl:variable name="eintragi"
            select="fn:escape-html-uri(concat('https://pmb.acdh.oeaw.ac.at/apis/tei/person/', $nummeri))"
            as="xs:string"/>
        <xsl:attribute name="ref">
            <xsl:choose>
                <xsl:when test="$nummeri = '2121'">
                    <xsl:text>https://d-nb.info/gnd/118609807</xsl:text>
                </xsl:when>
                <xsl:when
                    test="key('person-match', concat('pmb', $nummeri), $listperson)/tei:idno[@type = 'gnd' or @subtype = 'gnd'][1]">
                    <xsl:value-of
                        select="key('person-match', concat('pmb', $nummeri), $listperson)/tei:idno[@type = 'gnd' or @subtype = 'gnd'][1]"
                    />
                </xsl:when>
                <xsl:when
                    test="key('person-match', concat('pmb', $nummeri), $listperson)/tei:idno[@type = 'wikidata' or @subtype = 'wikidata'][1]">
                    <xsl:value-of
                        select="key('person-match', concat('pmb', $nummeri), $listperson)/tei:idno[@type = 'wikidata' or @subtype = 'wikidata'][1]"
                    />
                </xsl:when>
                <xsl:when test="doc-available($eintragi) and document($eintragi)/descendant::idno[@subtype = 'gnd'][1]">
                    <xsl:copy-of select="document($eintragi)/descendant::idno[@subtype = 'gnd'][1]"
                        copy-namespaces="no"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of
                        select="concat('https://pmb.acdh.oeaw.ac.at/entity/', $nummeri, '/')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>
    <!-- Das holt die Geonames-Nummer aus der PMB -->
    <xsl:template
        match="tei:placeName/@ref[contains(., 'pmb')] | tei:rs[@type = 'place']/@ref[contains(., 'pmb')]">
        <xsl:variable name="nummeri"
            select="replace(replace(replace(., '#', ''), 'pmb', ''), '/', '')"/>
        <xsl:variable name="eintragi"
            select="fn:escape-html-uri(concat('https://pmb.acdh.oeaw.ac.at/apis/tei/place/', $nummeri))"
            as="xs:string"/>
        <xsl:variable name="normdaten" as="xs:string?" select="mam:place-normdata(concat('pmb', $nummeri), 0)"/>
        <xsl:attribute name="ref">
            <xsl:choose>
                <xsl:when test="exists($normdaten)">
                    <xsl:value-of select="$normdaten"/>
                </xsl:when>
                <xsl:when test="doc-available($eintragi) and document($eintragi)/descendant::idno[@subtype = 'geonames'][1]">
                    <xsl:copy-of
                        select="document($eintragi)/descendant::idno[@subtype = 'geonames'][1]"
                        copy-namespaces="no"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of
                        select="concat('https://pmb.acdh.oeaw.ac.at/entity/', $nummeri, '/')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>
    <!-- Das holt die GND-Nummer für note/ref[@type=mentionsPerson] -->
    <xsl:template
        match="tei:ref[contains(@type, 'mentionsPerson')]/@target[contains(., 'pmb')]">
        <xsl:variable name="nummeri"
            select="replace(replace(replace(., '#', ''), 'pmb', ''), '/', '')"/>
        <xsl:variable name="eintragi"
            select="fn:escape-html-uri(concat('https://pmb.acdh.oeaw.ac.at/apis/tei/person/', $nummeri))"
            as="xs:string"/>
        <xsl:attribute name="target">
            <xsl:choose>
                <xsl:when test="$nummeri = '2121'">
                    <xsl:text>https://d-nb.info/gnd/118609807</xsl:text>
                </xsl:when>
                <xsl:when
                    test="key('person-match', concat('pmb', $nummeri), $listperson)/tei:idno[@type = 'gnd' or @subtype = 'gnd'][1]">
                    <xsl:value-of
                        select="key('person-match', concat('pmb', $nummeri), $listperson)/tei:idno[@type = 'gnd' or @subtype = 'gnd'][1]"
                    />
                </xsl:when>
                <xsl:when
                    test="key('person-match', concat('pmb', $nummeri), $listperson)/tei:idno[@type = 'wikidata' or @subtype = 'wikidata'][1]">
                    <xsl:value-of
                        select="key('person-match', concat('pmb', $nummeri), $listperson)/tei:idno[@type = 'wikidata' or @subtype = 'wikidata'][1]"
                    />
                </xsl:when>
                <xsl:when test="doc-available($eintragi) and document($eintragi)/descendant::idno[@subtype = 'gnd'][1]">
                    <xsl:copy-of select="document($eintragi)/descendant::idno[@subtype = 'gnd'][1]"
                        copy-namespaces="no"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of
                        select="concat('https://pmb.acdh.oeaw.ac.at/entity/', $nummeri, '/')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>
    <!-- Das holt die Geonames-Nummer für note/ref[@type=mentionsPlace] -->
    <xsl:template
        match="tei:ref[contains(@type, 'mentionsPlace')]/@target[contains(., 'pmb')]">
        <xsl:variable name="nummeri"
            select="replace(replace(replace(., '#', ''), 'pmb', ''), '/', '')"/>
        <xsl:variable name="eintragi"
            select="fn:escape-html-uri(concat('https://pmb.acdh.oeaw.ac.at/apis/tei/place/', $nummeri))"
            as="xs:string"/>
        <xsl:variable name="normdaten" as="xs:string?" select="mam:place-normdata(concat('pmb', $nummeri), 0)"/>
        <xsl:attribute name="target">
            <xsl:choose>
                <xsl:when test="exists($normdaten)">
                    <xsl:value-of select="$normdaten"/>
                </xsl:when>
                <xsl:when test="doc-available($eintragi) and document($eintragi)/descendant::idno[@subtype = 'geonames'][1]">
                    <xsl:copy-of
                        select="document($eintragi)/descendant::idno[@subtype = 'geonames'][1]"
                        copy-namespaces="no"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of
                        select="concat('https://pmb.acdh.oeaw.ac.at/entity/', $nummeri, '/')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>
    <xsl:template match="tei:correspContext"/>
</xsl:stylesheet>
