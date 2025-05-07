<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="#all" version="2.0">

    <xsl:output name="xml" method="xml" indent="yes" omit-xml-declaration="yes"/>

    <!-- directory of new files -->
    <xsl:param name="dir">../OEditions</xsl:param>

    <!-- output xml file for each letter tag with file name according to number of xml files in output directory (+1) -->
    <xsl:param name="n" select="count(collection(concat($dir, '?select=*.xml')))"/>
    <xsl:template match="/*">
        <xsl:for-each select="//tei:letter">
            <xsl:result-document href="{$dir}/X0{$n + position() +1}.xml">
                <TEI xmlns="http://www.tei-c.org/ns/1.0"
                    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                    xsi:schemaLocation="http://www.tei-c.org/ns/1.0 ../meta/asbwschema.xsd"
                    xml:id="L0XXXX"
                    xml:base="https://id.acdh.oeaw.ac.at/schnitzler/schnitzler-briefe/editions">
                    <teiHeader>
                        <fileDesc>
                            <titleStmt>
                                <title level="s">Arthur Schnitzler: Briefwechsel mit Autorinnen und
                                    Autoren</title>
                                <title level="a">Felix Salten an Arthur Schnitzler, XXXX</title>
                                <author ref="#pmb2167">Salten, Felix</author>
                                <editor>
                                    <name>Müller, Martin Anton</name>
                                    <name>Untner, Laura</name>
                                </editor>
                                <funder>
                                    <name>FWF - Der Wissenschaftsfonds</name>
                                    <address>
                                        <street>Sensengasse 1</street>
                                        <postCode>1090 Wien</postCode>
                                        <placeName>
                                            <country>A</country>
                                            <settlement>Wien</settlement>
                                        </placeName>
                                    </address>
                                </funder>
                            </titleStmt>
                            <editionStmt>
                                <edition>ASBW</edition>
                                <respStmt>
                                    <resp>Transkription und Kommentierung</resp>
                                    <name>Müller, Martin Anton</name>
                                    <name>Untner, Laura</name>
                                </respStmt>
                            </editionStmt>
                            <publicationStmt>
                                <publisher>Austrian Centre for Digital Humanities and Cultural
                                    Heritage</publisher>
                                <pubPlace>Vienna</pubPlace>
                                <date when="2023">2023</date>
                                <availability>
                                    <licence
                                        target="https://creativecommons.org/licenses/by/4.0/deed.de">
                                        <p>Sie dürfen: Teilen — das Material in jedwedem Format oder
                                            Medium vervielfältigen und weiterverbreiten Bearbeiten —
                                            das Material remixen, verändern und darauf aufbauen und
                                            zwar für beliebige Zwecke, sogar kommerziell.</p>
                                        <p>Der Lizenzgeber kann diese Freiheiten nicht widerrufen
                                            solange Sie sich an die Lizenzbedingungen halten. Unter
                                            folgenden Bedingungen:</p>
                                        <p>Namensnennung — Sie müssen angemessene Urheber- und
                                            Rechteangaben machen, einen Link zur Lizenz beifügen und
                                            angeben, ob Änderungen vorgenommen wurden. Diese Angaben
                                            dürfen in jeder angemessenen Art und Weise gemacht
                                            werden, allerdings nicht so, dass der Eindruck entsteht,
                                            der Lizenzgeber unterstütze gerade Sie oder Ihre Nutzung
                                            besonders. Keine weiteren Einschränkungen — Sie dürfen
                                            keine zusätzlichen Klauseln oder technische Verfahren
                                            einsetzen, die anderen rechtlich irgendetwas untersagen,
                                            was die Lizenz erlaubt.</p>
                                        <p>Hinweise:</p>
                                        <p>Sie müssen sich nicht an diese Lizenz halten hinsichtlich
                                            solcher Teile des Materials, die gemeinfrei sind, oder
                                            soweit Ihre Nutzungshandlungen durch Ausnahmen und
                                            Schranken des Urheberrechts gedeckt sind. Es werden
                                            keine Garantien gegeben und auch keine Gewähr geleistet.
                                            Die Lizenz verschafft Ihnen möglicherweise nicht alle
                                            Erlaubnisse, die Sie für die jeweilige Nutzung brauchen.
                                            Es können beispielsweise andere Rechte wie
                                            Persönlichkeits- und Datenschutzrechte zu beachten sein,
                                            die Ihre Nutzung des Materials entsprechend
                                            beschränken.</p>
                                    </licence>
                                </availability>
                                <idno type="handle"
                                    >XXXX</idno>
                            </publicationStmt>
                            <seriesStmt>
                                <p>Machine-Readable Transcriptions of the Correspondences of Arthur
                                    Schnitzler</p>
                            </seriesStmt>
                            <sourceDesc>
                                <listWit>
                                    <witness n="1">
                                        <objectType corresp="briefx"/>
                                        <msDesc>
                                            <msIdentifier>
                                                <country>GB</country>
                                                <settlement>Cambridge</settlement>
                                                <repository>University Library</repository>
                                                <idno>Schnitzler, B 89, A 2</idno>
                                            </msIdentifier>
                                            <physDesc>
                                                <objectDesc>
                                                    <supportDesc>
                                                        <extent>
                                                            <measure unit="blatt" quantity=""/>
                                                            <measure unit="seite" quantity=""/>
                                                        </extent>
                                                    </supportDesc>
                                                </objectDesc>
                                                <handDesc>
                                                  <handNote medium="" style="lateinische-kurrent"/>
                                                </handDesc>
                                                <additions>
                                                    <incident type="archival">
                                                        <desc>XXXXmit Bleistift von unbekannter Hand nummeriert: »<quote>x</quote>«</desc>
                                                    </incident>
                                                </additions>
                                            </physDesc>
                                        </msDesc>
                                    </witness>
                                </listWit>
                            </sourceDesc>
                        </fileDesc>
                        <profileDesc>
                            <langUsage>
                                <language ident="de-AT">German</language>
                            </langUsage>
                            <correspDesc>
                                <correspAction type="sent">
                                    <persName ref="#11485">Goldmann, Paul</persName>
                                    <date when="1896-" n="">XXXX</date>
                                    <placeName ref="#182">Paris</placeName>
                                </correspAction>
                                <correspAction type="received">
                                    <persName ref="#2121">Schnitzler, Arthur</persName>
                                    <placeName ref="#50">Wien</placeName>
                                </correspAction>
                            </correspDesc>
                        </profileDesc>
                        <encodingDesc>
                            <refsDecl>
                                <ab>References to Arthur Schnitzler’s diary online consist of the
                                    relevant dates only, e.g. @type="schnitzlerDiary"
                                    @target="1891-05-15". The complete URI is:
                                    'https://schnitzler-tagebuch.acdh.oeaw.ac.at/entry__1891-05-15.html'
                                </ab>
                            </refsDecl>
                        </encodingDesc>
                        <revisionDesc status="proposed">
                            <change who="LU" when="2022-08-16">Angelegt</change>
                        </revisionDesc>
                    </teiHeader>
                    <text>
                        <body>
                            <xsl:element name="div" namespace="http://www.tei-c.org/ns/1.0">
                                <xsl:attribute name="type">
                                    <xsl:value-of select="'writingSession'"/>
                                </xsl:attribute>
                                <xsl:attribute name="n">
                                    <xsl:value-of select="'1'"/>
                                </xsl:attribute>
                                <xsl:copy-of select="."/>
                            </xsl:element>
                        </body>
                    </text>
                </TEI>
            </xsl:result-document>
        </xsl:for-each>
    </xsl:template>

</xsl:stylesheet>
