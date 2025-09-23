<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:foo="whatever" xmlns:tei="http://www.tei-c.org/ns/1.0" version="3.0">
    <!-- Diese Funktion hier bekommt einen Datumswert übermittelt und formatiert ihn mit Abständen zwischen den Punkten, also 3. 4. 2023 etc.,
    sollte auch auf römische Monatsangaben anwendbar sein-->
    <xsl:param name="spacy" select="'\,'" as="xs:string"/>
    <!-- Das Zeichen, das als Abstand nach dem Punkt gesetzt werden soll -->
    <xsl:function name="foo:date-translate" as="xs:string?">
        <xsl:param name="date-string" as="xs:string?"/>
        <xsl:variable name="clean-date" select="normalize-space(if (contains($date-string, '&lt;')) then substring-before($date-string, '&lt;') else $date-string)"/>

        <xsl:choose>
            <xsl:when test="$clean-date = '' or empty($clean-date)"/>
            <xsl:when test="contains($clean-date, ' – ')">
                <xsl:variable name="datum1" select="foo:datum-analyze(substring-before($clean-date, ' – '))"/>
                <xsl:variable name="datum2" select="foo:datum-analyze(substring-after($clean-date, ' – '))"/>
                <xsl:value-of select="concat($datum1, if ($datum1 != $datum2 and (contains(concat($datum1, $datum2), ' ') or contains(concat($datum1, $datum2), $spacy))) then ' – ' else '–', $datum2)"/>
            </xsl:when>
            <xsl:when test="matches($clean-date, '^\[um\s(.*?)\sv\.\s{0,1}u\.\s{0,1}Z\.(\?)?\]$')">
                <xsl:analyze-string select="$clean-date" regex="^\[um\s(.*?)\s(v\.\s{{0,1}}u\.\s{{0,1}}Z\.)(\?)?\]$">
                    <xsl:matching-substring>
                        <xsl:value-of select="concat('{[}um ', foo:datum-analyze(regex-group(1)), ' ', regex-group(2), if (regex-group(3)) then regex-group(3) else '', '{]}')"/>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </xsl:when>
            <xsl:when test="matches($clean-date, '^\[um\s(.*?)(\?)?\]$') and not(matches($clean-date, 'v\.\s{0,1}u\.\s{0,1}Z\.'))">
                <xsl:analyze-string select="$clean-date" regex="^\[um\s(.*?)(\?)?\]$">
                    <xsl:matching-substring>
                        <xsl:value-of select="concat('{[}um ', foo:datum-analyze(regex-group(1)), if (regex-group(2)) then regex-group(2) else '', '{]}')"/>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </xsl:when>
            <xsl:when test="matches($clean-date, '^\[(.*?)(\?)?\]$') and not(starts-with($clean-date, '[um'))">
                <xsl:analyze-string select="$clean-date" regex="^\[(.*?)(\?)?\]$">
                    <xsl:matching-substring>
                        <xsl:value-of select="concat('{[}', foo:datum-analyze(regex-group(1)), if (regex-group(2)) then regex-group(2) else '', '{]}')"/>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </xsl:when>
            <xsl:when test="matches($clean-date, '^um\s(.*?)$')">
                <xsl:value-of select="concat('um ', foo:datum-analyze(substring-after($clean-date, 'um ')))"/>
            </xsl:when>
            <xsl:when test="matches($clean-date, '^(.*?)\sv\.\s{0,1}u\.\s{0,1}Z\.(\?)?$')">
                <xsl:value-of select="concat(foo:datum-analyze(normalize-space(substring-before($clean-date, ' v.'))), ' v.', $spacy, 'u.', $spacy, 'Z.', if (ends-with($clean-date, '?')) then '?' else '')"/>
            </xsl:when>
            <xsl:when test="matches($clean-date, '^(.*?)\?$')">
                <xsl:value-of select="concat(foo:datum-analyze(substring-before($clean-date, '?')), '?')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="foo:datum-analyze($clean-date)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <xsl:function name="foo:datum-analyze">
        <xsl:param name="datem" as="xs:string"/>
        <xsl:variable name="datom" as="xs:string" select="fn:normalize-space($datem)"/>
        <xsl:analyze-string select="$datom" regex="^(\d{{4}})-0?(\d+)-0?(\d+)$">
            <xsl:matching-substring>
                <xsl:variable name="day">
                    <xsl:choose>
                        <xsl:when test="starts-with(regex-group(3), '0')">
                            <xsl:value-of select="substring(regex-group(3), 2)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="regex-group(3)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="month">
                    <xsl:choose>
                        <xsl:when test="starts-with(regex-group(2), '0')">
                            <xsl:value-of select="substring(regex-group(2), 2)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="regex-group(2)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:value-of
                    select="concat($day, '.', $spacy, $month, '.', $spacy, number(regex-group(1)))"
                />
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <!-- Spezifisches Pattern für DD.MM.YYYY ohne Leerzeichen -->
                <xsl:analyze-string select="."
                    regex="^(\d+)\.(\d+)\.(\d+)$">
                    <xsl:matching-substring>
                        <xsl:variable name="day">
                            <xsl:value-of select="if (starts-with(regex-group(1), '0') and string-length(regex-group(1)) > 1) then substring(regex-group(1), 2) else regex-group(1)"/>
                        </xsl:variable>
                        <xsl:variable name="month">
                            <xsl:value-of select="if (starts-with(regex-group(2), '0') and string-length(regex-group(2)) > 1) then substring(regex-group(2), 2) else regex-group(2)"/>
                        </xsl:variable>
                        <xsl:value-of select="concat($day, '.', $spacy, $month, '.', $spacy, regex-group(3))"/>
                    </xsl:matching-substring>
                    <xsl:non-matching-substring>
                        <xsl:analyze-string select="."
                            regex="^(\d{{1,2}})\.(\d{{1,2}})\.(\d{{4}})">
                            <xsl:matching-substring>
                                <xsl:variable name="day">
                                    <xsl:value-of select="if (starts-with(regex-group(1), '0') and string-length(regex-group(1)) > 1) then substring(regex-group(1), 2) else regex-group(1)"/>
                                </xsl:variable>
                                <xsl:variable name="month">
                                    <xsl:value-of select="if (starts-with(regex-group(2), '0') and string-length(regex-group(2)) > 1) then substring(regex-group(2), 2) else regex-group(2)"/>
                                </xsl:variable>
                                <xsl:value-of
                                    select="concat($day, '.', $spacy, $month, '.', $spacy, regex-group(3))"
                                />
                            </xsl:matching-substring>
                            <xsl:non-matching-substring>
                        <xsl:choose>
                            <xsl:when test="contains(., '&#8239;')">
                                <xsl:value-of select="."/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:analyze-string select="."
                                    regex="^(\d{{1,2}})(\.)(\s*)(\d{{1,2}})(\.)(\s*)(\d{{2,4}})$">
                                    <xsl:matching-substring>
                                        <xsl:variable name="day">
                                            <xsl:choose>
                                                <xsl:when test="starts-with(regex-group(1), '0') and string-length(regex-group(1)) > 1">
                                                  <xsl:value-of
                                                  select="substring(regex-group(1), 2)"/>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                  <xsl:value-of select="regex-group(1)"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:variable>
                                        <xsl:variable name="month">
                                            <xsl:choose>
                                                <xsl:when test="starts-with(regex-group(4), '0') and string-length(regex-group(4)) > 1">
                                                  <xsl:value-of
                                                  select="substring(regex-group(4), 2)"/>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                  <xsl:value-of select="regex-group(4)"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:variable>
                                        <xsl:value-of
                                            select="concat($day, '.', $spacy, $month, '.', $spacy, number(regex-group(7)))"
                                        />
                                    </xsl:matching-substring>
                                    <xsl:non-matching-substring>
                                        <xsl:value-of select="replace(replace(concat('', .), '\[', '{[}'), '\]', '{]}')"/>
                                    </xsl:non-matching-substring>
                                </xsl:analyze-string>
                            </xsl:otherwise>
                        </xsl:choose>
                            </xsl:non-matching-substring>
                        </xsl:analyze-string>
                    </xsl:non-matching-substring>
                </xsl:analyze-string>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:function>
    
</xsl:stylesheet>
