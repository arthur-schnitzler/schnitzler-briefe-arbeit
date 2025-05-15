<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:number="http://dummy/" xmlns="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="#all"
    xmlns:functx="http://www.functx.com" version="3.0"
    xmlns:fn="http://www.w3.org/2005/xpath-functions">
    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:output indent="yes" method="xml" encoding="utf-8" omit-xml-declaration="false"/>
    
    <xsl:template match="tei:objectDesc/tei:desc[@subtype='rohrpost']">
        <xsl:element name="desc" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:attribute name="type">
                <xsl:value-of select="@type"/>
            </xsl:attribute>
            <xsl:copy-of select="node()"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="tei:additions[parent::tei:physDesc/tei:objectDesc/tei:desc[@subtype='rohrpost']]">
        <xsl:element name="additions" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:element name="incident" namespace="http://www.tei-c.org/ns/1.0">
                <xsl:attribute name="type">
                    <xsl:text>postal</xsl:text>
                </xsl:attribute>
                <xsl:element name="desc" namespace="http://www.tei-c.org/ns/1.0">
                <xsl:text>Rohrpost</xsl:text></xsl:element>
            </xsl:element><xsl:copy-of select="node()"/>
            </xsl:element>
    </xsl:template>
    
    
    <!--<xsl:template match="tei:physDesc">
        <xsl:element name="physDesc" namespace="http://www.tei-c.org/ns/1.0">
       <xsl:if test="tei:objectDesc">
           <xsl:element name="objectDesc" namespace="http://www.tei-c.org/ns/1.0">
               <xsl:copy-of select="tei:objectDesc/node()"/>
           </xsl:element>
       </xsl:if> 
        <xsl:if test="tei:handDesc">
            <xsl:element name="handDesc" namespace="http://www.tei-c.org/ns/1.0">
                <xsl:if test="tei:handDesc/@hands">
                    <xsl:attribute name="hands">
                        <xsl:value-of select="tei:handDesc/@hands"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:copy-of select="tei:handDesc/node()"/>
            </xsl:element>
        </xsl:if> 
            <xsl:if test="tei:typeDesc">
                <xsl:element name="typeDesc" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:copy-of select="tei:typeDesc/node()"/>
                </xsl:element>
            </xsl:if> 
            
            <xsl:if test="tei:additions">
                    <xsl:copy-of select="tei:additions"/>
            </xsl:if> 
        
       
        </xsl:element>
    </xsl:template>-->
    
    
  <!--  <xsl:template match="tei:additions">
        <xsl:element name="additions" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:for-each select="tei:incident[@type='supplement']">
                <xsl:element namespace="http://www.tei-c.org/ns/1.0" name="incident">
                    <xsl:attribute name="type">
                        <xsl:text>supplement</xsl:text>
                    </xsl:attribute>
                    <xsl:copy-of select="node()"/>
                </xsl:element>
            </xsl:for-each>
            <xsl:for-each select="tei:incident[@type='postal']">
                <xsl:element namespace="http://www.tei-c.org/ns/1.0" name="incident">
                    <xsl:attribute name="type">
                        <xsl:text>postal</xsl:text>
                    </xsl:attribute>
                    <xsl:copy-of select="node()"/>
                </xsl:element>
            </xsl:for-each>
            <xsl:for-each select="tei:incident[@type='reveicer']">
                <xsl:element namespace="http://www.tei-c.org/ns/1.0" name="incident">
                    <xsl:attribute name="type">
                        <xsl:text>receiver</xsl:text>
                    </xsl:attribute>
                    <xsl:copy-of select="node()"/>
                </xsl:element>
            </xsl:for-each>
            <xsl:for-each select="tei:incident[@type='archival']">
                <xsl:element namespace="http://www.tei-c.org/ns/1.0" name="incident">
                    <xsl:attribute name="type">
                        <xsl:text>archival</xsl:text>
                    </xsl:attribute>
                    <xsl:copy-of select="node()"/>
                </xsl:element>
            </xsl:for-each>
            <xsl:for-each select="tei:incident[@type='additional-information']">
                <xsl:element namespace="http://www.tei-c.org/ns/1.0" name="incident">
                    <xsl:attribute name="type">
                        <xsl:text>additional-information</xsl:text>
                    </xsl:attribute>
                    <xsl:copy-of select="node()"/>
                </xsl:element>
            </xsl:for-each>
            <xsl:for-each select="tei:incident[@type='editorial']">
                <xsl:element namespace="http://www.tei-c.org/ns/1.0" name="incident">
                    <xsl:attribute name="type">
                        <xsl:text>editorial</xsl:text>
                    </xsl:attribute>
                    <xsl:copy-of select="node()"/>
                </xsl:element>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>-->
    
    
    <!--
        
         <xsl:template match="tei:TEI[descendant::tei:body/tei:div[@type='address']/tei:address]/descendant::tei:objectDesc[tei:desc/@type='brief' and not(tei:desc/@type='umschlag')]">
        <xsl:element name="objectDesc" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:copy-of select="node()"/>
            <xsl:element name="desc" namespace="http://www.tei-c.org/ns/1.0">
                <xsl:attribute name="type">umschlag</xsl:attribute>
                <xsl:attribute name="new">
                    <xsl:text>yes</xsl:text>
                </xsl:attribute>
            </xsl:element>
        </xsl:element>
        
    </xsl:template>
    
    <xsl:template match="tei:physDesc[not(tei:handDesc) and tei:p/tei:supportDesc/tei:handDesc]">
        <xsl:element name="physDesc" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:element name="handDesc" namespace="http://www.tei-c.org/ns/1.0">
                <xsl:attribute name="new">
                    <xsl:text>ja</xsl:text>
                </xsl:attribute>
                <xsl:copy-of select="tei:p/tei:supportDesc/tei:handDesc/tei:handNote"/>
            </xsl:element>
            <xsl:copy-of select="node()"/>
        </xsl:element>
    </xsl:template>-->
    
   <!-- <xsl:template match="tei:physDesc[tei:p/tei:supportDesc/tei:handNote and tei:handDesc[not(child::*[1])]]">
        <xsl:element name="physDesc" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:element name="handDesc" namespace="http://www.tei-c.org/ns/1.0">
                <xsl:attribute name="new">
                    <xsl:text>ja</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="hands">
                    <xsl:value-of select="tei:handDesc/@hands"/>
                </xsl:attribute>
                <xsl:copy-of select="tei:p/tei:supportDesc/tei:handNote"/>
            </xsl:element>
            <xsl:copy-of select="node()"/>
        </xsl:element>
    </xsl:template>-->
    
    
        
    
    
   <!-- <xsl:template match="tei:handDesc[parent::tei:physDesc[tei:p/tei:supportDesc/tei:handDesc/@hands and not(tei:p/tei:supportDesc//tei:handNote)]]">
        <xsl:element name="handDesc" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:attribute  name="hands">
                <xsl:value-of select="ancestor::tei:physDesc/tei:p/tei:supportDesc/tei:handDesc[@hands]/@hands"/>
            </xsl:attribute>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
    
    <xsl:template match="tei:physDesc[tei:p/tei:supportDesc/tei:handDesc and not(tei:handDesc)]">
        <xsl:element name="physDesc" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:copy-of select="tei:p/tei:supportDesc/tei:handDesc"/>
            <xsl:copy-of select="child::*"/>
        </xsl:element>
        
        
    </xsl:template>
    -->
   <!-- <xsl:template match="tei:physDesc/tei:p/tei:handDesc[@hands]">
        
        
        
    </xsl:template>
    -->
    
   <!-- <xsl:template match="tei:physDesc/tei:p[tei:supportDesc[normalize-space(.)='']]">
         <xsl:choose>
             <xsl:when test="not(preceding-sibling::tei:objectDesc or following-sibling::tei:objectDesc) and descendant::tei:desc">
                 <xsl:element name="objectDesc" namespace="http://www.tei-c.org/ns/1.0">
                 <xsl:copy-of select="descendant::tei:desc"/>
                 </xsl:element>
             </xsl:when>
         </xsl:choose>
         <xsl:choose>
             <xsl:when test="not(preceding-sibling::tei:handDesc or following-sibling::tei:handDesc) and descendant::tei:handDesc">
                 <xsl:copy-of select="descendant::tei:handDesc"/>
             </xsl:when>
             <xsl:when test="not(preceding-sibling::tei:handDesc or following-sibling::tei:handDesc) and descendant::tei:handNote">
                 <xsl:element name="handDesc" namespace="http://www.tei-c.org/ns/1.0">
                 <xsl:copy-of select="descendant::tei:handNote"/>
                 </xsl:element>
             </xsl:when>
         </xsl:choose>
         
         
     </xsl:template>
        
    <xsl:template match="tei:physDesc[descendant::tei:p/tei:supportDesc[normalize-space(.)='']/tei:desc]/tei:objectDesc">
        <xsl:element name="objectDesc" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:copy-of select="parent::tei:physDesc/tei:p/tei:supportDesc/tei:desc"/>
            <xsl:copy-of select="child::*"/>
        </xsl:element>
    </xsl:template>    
        -->
        
   <!-- <xsl:template match="tei:physDesc[descendant::tei:p/tei:supportDesc[normalize-space(.)='']/tei:handDesc]/tei:handDesc|tei:physDesc[descendant::tei:p/tei:supportDesc[normalize-space(.)='']/tei:handNote]/tei:handDesc">
        <xsl:element name="handDesc" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:copy-of select="parent::tei:physDesc/tei:p/tei:supportDesc/descendant::tei:handNote"/>
            <xsl:copy-of select="child::*"/>
        </xsl:element>
    </xsl:template>    -->
    
                  
    
              
          
          
        
       
   
</xsl:stylesheet>
