<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="#all">
    <!-- Für Klarheit, Identity-Template -->
    <xsl:mode on-no-match="shallow-copy"/>
    <!-- Hauptregel: Ersetze <pmb ref="pmb296012"/> -->
    <xsl:template match="*:pmb">
        <xsl:variable name="ref" select="replace(replace(@ref, '#', ''), 'pmb', '')"/>
        <xsl:element name="rs" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:attribute name="type">
                <xsl:text>event</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="ref">
                <xsl:value-of select="concat('#pmb', $ref)"/>
            </xsl:attribute>
            <xsl:variable name="event-url"
                select="concat('https://pmb.acdh.oeaw.ac.at/apis/tei/event/', $ref)"/>
            <xsl:variable name="event-doc" select="parse-xml(unparsed-text($event-url))"/>
            <xsl:variable name="event" select="$event-doc/*"/>
            <xsl:variable name="date" select="$event/@when-iso"/>
            <xsl:variable name="event-type" select="$event/*:eventName/@n"/>
            <xsl:variable name="listBibl" as="node()">
                <xsl:element name="listBibl" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:for-each
                        select="$event/*:listBibl/*:bibl[not(child::*:note = 'wird rezensiert in') and *:title]">
                        <xsl:variable name="key"
                            select="replace(replace(*:title/@key, '#', ''), 'pmb', '')"/>
                        <xsl:element name="bibl" namespace="http://www.tei-c.org/ns/1.0">
                            <xsl:element name="title" namespace="http://www.tei-c.org/ns/1.0">
                                <xsl:attribute name="key">
                                    <xsl:value-of select="concat('#pmb', $key)"/>
                                </xsl:attribute>
                                <xsl:value-of select="normalize-space(*:title)"/>
                            </xsl:element>
                            <xsl:variable name="work-url"
                                select="concat('https://pmb.acdh.oeaw.ac.at/apis/tei/work/', $key)"/>
                            <xsl:variable name="work-doc"
                                select="parse-xml(unparsed-text($work-url))"/>
                            <xsl:for-each select="$work-doc//*:author[@role = 'hat-geschaffen']">
                                <xsl:element name="author" namespace="http://www.tei-c.org/ns/1.0">
                                    <xsl:attribute name="key">
                                        <xsl:value-of select="replace(@key, 'person__', 'pmb')"/>
                                    </xsl:attribute>
                                    <xsl:value-of select="normalize-space(.)"/>
                                </xsl:element>
                            </xsl:for-each>
                        </xsl:element>
                    </xsl:for-each>
                </xsl:element>
            </xsl:variable>
            <xsl:variable name="event-place" select="$event/*:listPlace/*:place[1]/*:placeName[1]"
                as="node()?"/>
            <xsl:variable name="event-org"
                select="$event/*:note[@type = 'listorg']/*:listOrg[*:org[@role = 'veranstaltet von']]"
                as="node()?"/>
            <xsl:choose>
                <xsl:when
                    test="ends-with($event-type, 'ung') or ends-with($event-type, 'iere') or ends-with($event-type, 'esse') or ends-with($event-type, 'iere') or ends-with($event-type, 'robe') or ends-with($event-type, 'ée') or ends-with($event-type, 'vue') or ends-with($event-type, 'oute') or ends-with($event-type, 'neipe') or ends-with($event-type, 'age') or ends-with($event-type, 'kunft') or ends-with($event-type, 'zeit')">
                    <xsl:text>Die </xsl:text>
                </xsl:when>
                <xsl:when
                    test="ends-with($event-type, 'gericht') or ends-with($event-type, 'ieté') or ends-with($event-type, 'onzert') or ends-with($event-type, 'rio') or ends-with($event-type, 'chen') or ends-with($event-type, 'fest') or ends-with($event-type, 'spiel') or ends-with($event-type, 'iner') or ends-with($event-type, 'ouper') or ends-with($event-type, 'kett') or ends-with($event-type, 'uell') or ends-with($event-type, 'reffen') or ends-with($event-type, 'ival')">
                    <xsl:text>Das </xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>Der </xsl:text>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:value-of select="$event-type"/>
            <xsl:text> von </xsl:text>
            <xsl:for-each select="$listBibl/*:bibl">
                <xsl:element name="rs" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:attribute name="type">
                        <xsl:text>work</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="ref">
                        <xsl:value-of select="*:title/@key"/>
                    </xsl:attribute>
                    <xsl:value-of select="*:title"/>
                </xsl:element>
                <xsl:if test="*:author">
                    <xsl:text> von </xsl:text>
                    <xsl:for-each select="*:author">
                        <xsl:element name="rs" namespace="http://www.tei-c.org/ns/1.0">
                            <xsl:attribute name="type">
                                <xsl:text>person</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="ref">
                                <xsl:value-of select="concat('#', @key)"/>
                            </xsl:attribute>
                            <xsl:choose>
                                <xsl:when test="contains(., ', ')">
                                    <xsl:value-of select="concat(substring-after(., ', '), ' ', substring-before(., ', '))"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="."/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:element>
                    </xsl:for-each>
                </xsl:if>
                <xsl:if test="not(position() = last())">
                    <xsl:text>, </xsl:text>
                </xsl:if>
            </xsl:for-each>
            <xsl:text> fand am </xsl:text>
            <xsl:element name="date" namespace="http://www.tei-c.org/ns/1.0">
                <xsl:attribute name="when">
                    <xsl:value-of select="$date"/>
                </xsl:attribute>
                <xsl:value-of select="format-date(xs:date($date), '[D1].&#160;[M1].&#160;[Y0001]')"
                />
            </xsl:element>
            <xsl:if test="$event-org/*:org[@role = 'veranstaltet von'][1]">
                <xsl:text> am </xsl:text>
                <xsl:for-each select="$event-org/*:org[@role = 'veranstaltet von']/*:orgName">
                    <xsl:element name="rs" namespace="http://www.tei-c.org/ns/1.0">
                        <xsl:attribute name="type">
                            <xsl:text>org</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="ref">
                            <xsl:value-of select="concat('#', @key)"/>
                        </xsl:attribute>
                        <xsl:value-of select="."/>
                    </xsl:element>
                    <xsl:if test="not(position() = last())">
                        <xsl:text>, </xsl:text>
                    </xsl:if>
                </xsl:for-each>
            </xsl:if>
            <xsl:if test="$event-place/@key">
                <xsl:text> im </xsl:text>
                <xsl:element name="rs" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:attribute name="type">
                        <xsl:text>place</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="ref">
                        <xsl:value-of select="concat('#', $event-place/@key)"/>
                    </xsl:attribute>
                    <xsl:value-of select="$event-place"/>
                </xsl:element>
            </xsl:if>
            <xsl:text> statt.</xsl:text>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
