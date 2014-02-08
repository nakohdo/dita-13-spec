<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:rng="http://relaxng.org/ns/structure/1.0"
  xmlns:rnga="http://relaxng.org/ns/compatibility/annotations/1.0"
  xmlns:rng2ditadtd="http://dita.org/rng2ditadtd"
  xmlns:relpath="http://dita2indesign/functions/relpath"
  xmlns:a="http://relaxng.org/ns/compatibility/annotations/1.0"
  xmlns:str="http://local/stringfunctions"
  xmlns:ditaarch="http://dita.oasis-open.org/architecture/2005/"
  xmlns:dita="http://dita.oasis-open.org/architecture/2005/"
  xmlns:rngfunc="http://dita.oasis-open.org/dita/rngfunctions"
  xmlns:local="http://local-functions"
  exclude-result-prefixes="xs xd rng rnga relpath a str ditaarch dita rngfunc local"
  version="2.0">
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p><xd:b>Created on:</xd:b> Jan 31, 2014</xd:p>
      <xd:p><xd:b>Author:</xd:b> ekimber</xd:p>
      <xd:p>Handles generation of the *Mod.xsd and *Grp.xsd files from
      their corresponding RelaxNG module.</xd:p>
      <xd:p>Structural modules and the base modules separate the 
      per-element-type groups from the element type declarations
      into separate files. Domains put both in one file.</xd:p>
    </xd:desc>
  </xd:doc>
  
  <xsl:template match="/" mode="groupFile moduleFile">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <xsl:template mode="groupFile" match="rng:include">
   <!-- Nothing to do -->
  </xsl:template>
  
  <xsl:template mode="moduleFile" match="rng:include">
   <!-- What to do ??? -->
  </xsl:template>
  
  <xsl:template mode="groupFile" match="rng:grammar">
    <xsl:message> + [INFO] === <xsl:value-of select="rngfunc:getModuleShortName(.)"/>: Generating Grp.xsd file...</xsl:message>
    <xsl:apply-templates mode="header-comment" select="."/>
    <xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
      <xsl:apply-templates mode="#current"/>
    </xs:schema>
  </xsl:template>
  
  <xsl:template mode="moduleFile" match="rng:grammar">
    
    <xsl:message> + [INFO] === <xsl:value-of select="rngfunc:getModuleShortName(.)"/>: Generating Mod.xsd file...</xsl:message>
    
    <xsl:apply-templates mode="header-comment" select="."/>
    <xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
      <xsl:if test="rngfunc:getModuleShortName(.) = 'topic'">
          <xsl:comment> ==================== Import Section ======================= </xsl:comment>
          <xsl:text>&#x0a;</xsl:text>
          <xs:import namespace="http://dita.oasis-open.org/architecture/2005/" schemaLocation="../../base/xsd/ditaarch.xsd"/>
          <xsl:text>&#x0a;</xsl:text>
          <xsl:text>&#x0a;</xsl:text>
      </xsl:if>
      
      
      <xs:annotation>
        <xs:appinfo>
          <dita:domainsModule xmlns:dita="http://dita.oasis-open.org/architecture/2005/"
            ><xsl:value-of select="rngfunc:getDomainsContribution(.)"/></dita:domainsModule>
        </xs:appinfo>
      </xs:annotation>
      <xsl:text>&#x0a;</xsl:text>
      
      <xsl:choose>
        <xsl:when test="rngfunc:getModuleShortName(.) = ('commonElements', 'tblDecl', 'metaDecl') or rngfunc:getModuleType(.) = ('topic', 'map')">
          <!-- No groups in the Mod.xsd file -->
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates mode="groupFile" select="rng:define/rng:element"/>
        </xsl:otherwise>
      </xsl:choose>
      
      <xsl:text>&#x0a;</xsl:text>
      <xsl:variable name="domainPrefix" 
        as="xs:string"
        select="concat(rngfunc:getModuleShortName(.), '-')"
      /> 
      
      <!-- CommonElementsMod has some additional declarations specific to the XSD that
           have no direct correlate in the RNG declarations.
        -->
      
      <xsl:if test="rngfunc:getModuleShortName(.) = 'commonElements'">
        	<xs:attribute name="class" type="xs:string">
        		<xs:annotation>
        			<xs:documentation>
                        The class attribute supports specialization. Its predefined values help 
                        the output transforms work correctly with ranges of related content. 
                    </xs:documentation>
        		</xs:annotation>
        	</xs:attribute>

      </xsl:if>

      <!-- The handleDefinitionsForMod mode handles all definitions except the 
           element-specific .content and .attributes definitions, which are
           handled through the rng:element processing.
           
           This mode should produce all other groups and attribute groups
           that should result from rng:define elements.
        -->
           
      <xsl:apply-templates mode="handleDefinitionsForMod" 
        select="(rng:define | rng:include) except 
                    (rng:define[.//rng:attribute[@name='class']])"
        >
        <xsl:with-param name="domainPrefix" select="$domainPrefix" tunnel="yes" as="xs:string" />
      </xsl:apply-templates>
    </xs:schema>
  </xsl:template>
  
  <!-- ====================
       Mode groupFile
       
       The groups are equivalent to the element-type-name 
       entities in the DTDs. There is one per unique element
       types.
       
   <xs:group name="tt">
      <xs:sequence>
         <xs:choice>
            <xs:element ref="tt"/>
         </xs:choice>
      </xs:sequence>
   </xs:group>

       ==================== -->
  <xsl:template mode="groupFile" match="rng:define">
    <xsl:apply-templates select="rng:element" mode="#current"/>
  </xsl:template>

  <xsl:template mode="groupFile" match="rng:element">
     <xs:group name="{@name}">
        <xs:sequence>
           <xs:choice>
              <xs:element ref="{@name}"/>
           </xs:choice>
        </xs:sequence>
     </xs:group>
    <xsl:text>&#x0a;</xsl:text>
  </xsl:template>

  <xsl:template mode="groupFile" match="a:* | dita:moduleDesc">
    <!-- Ignore documentation -->
  </xsl:template>

  <xsl:template mode="groupFile" match="*" priority="-1">
    <xsl:message> + [WARN] groupFile: Unhandled element <xsl:value-of select="concat(name(..), '/', name(.))"/></xsl:message>
  </xsl:template>
  
  <!-- ============================
       Mode handleDefinitionsForMod
       ============================ -->

  <!-- Class attributes are handled in a separate mode -->
  <xsl:template match="rng:define[.//rng:attribute[@name='class']]" mode="handleDefinitionsForMod" priority="10"/>
  

  <xsl:template match="rng:define[starts-with(@name, concat(rngfunc:getModuleShortName(ancestor::rng:grammar), '-'))]" 
    mode="handleDefinitionsForMod" priority="30"
  >
    <!-- Ignored for XSD output -->
  </xsl:template>
  
  <xsl:template match="rng:define[@combine = 'choice']" mode="handleDefinitionsForMod" priority="20">
      <!-- Domain integration pattern. Not output in the XSD. -->
  </xsl:template>


  <xsl:template match="rng:define[ends-with(@name, '.content') or ends-with(@name, '.attributes')]" 
    mode="handleDefinitionsForMod" priority="15">
    
    <xsl:if test="ends-with(@name, '.attributes')">
      <xsl:if test="count(tokenize(@name, '\.')) gt 2">
        <xsl:next-match/><!-- Handle cases like "dita.table.attributes" -->
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template match="rng:define[count(rng:*)=1 and rng:ref and key('attlistIndex',@name)]" 
                mode="handleDefinitionsForMod" priority="10">
      <!-- .attlist pointing to .attributes, ignore -->
  </xsl:template>

  <xsl:template match="rng:define[count(rng:*)=1 and rng:ref and key('definesByName',rng:ref/@name)/rng:element]" 
                mode="handleDefinitionsForMod" priority="10">
      <!-- reference to element name in this module, will be in the group file -->
  </xsl:template>
  
  <xsl:template match="rng:define[count(rng:*)=1 and rng:ref and 
                                  not(key('definesByName',rng:ref/@name)) and 
                                  ends-with(rng:ref/@name, '.element')]" 
                mode="handleDefinitionsForMod" priority="20">
      <!-- reference to element name in another module, will be in group file -->
  </xsl:template>

  <xsl:template match="rng:define" mode="handleDefinitionsForMod" priority="8">
    <!-- Main template for generating group declarations from defines. 
    
         Note that the .content and .attributes handling is driven from within the rng:element
    -->
    <xsl:param name="domainPrefix" tunnel="yes" as="xs:string" />
    <xsl:message> + [DEBUG] handleDefinitionsForMod: Main template: Handling define: <xsl:value-of select="@name"/></xsl:message>

    <xsl:choose>
      <xsl:when test="$domainPrefix and not($domainPrefix='') and starts-with(@name, $domainPrefix)">
        <!-- Should never get here so this is belt to go with suspenders -->
        <!--  Domain extension pattern, not output in the .mod file (goes in shell DTDs) -->
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates mode="generate-group-decl-from-define" select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template mode="handleDefinitionsForMod" match="rng:include">
    <!-- Suppress, at least in the topicMod.xsd -->
  </xsl:template>

  <xsl:template mode="handleDefinitionsForMod" match="*" priority="-1">
    <xsl:message> - [WARN] handleDefinitionsForMod: Unhandled element <xsl:value-of select="concat(name(..), '/', name(.))"/></xsl:message>
  </xsl:template>
  
  <!-- ====================================
       Mode generate-group-decl-from-define
       ==================================== -->

  <xsl:template mode="generate-group-decl-from-define" match="rng:define[@name = 'arch-atts']" priority="10">
    <!-- arch-atts declaration is hard-coded -->
  </xsl:template>

  <xsl:template mode="generate-group-decl-from-define" match="rng:define[rng:element]" priority="10">
    <xsl:apply-templates select="rng:element" mode="handleDefinitionsForMod"/>
  </xsl:template>

  <xsl:template mode="generate-group-decl-from-define" match="rng:define">
    
    <!-- FIXME: The following is a hack that depends on a consistent naming convention
         for attribute sets.
         
         The more complete solution I think requires producing a single-document resolved
         grammar (e.g., RNG simplification) and then examining the define in that 
         grammar to see if it has any attribute declarations.
      -->
    <xsl:variable name="isAttSet" as="xs:boolean"
      select="matches(@name, '-atts|attribute|\.att') or .//rng:attribute"
    />
    
<!--    <xsl:message> + [DEBUG] generate-group-decl-from-define: name="<xsl:value-of select="@name"/>"</xsl:message>
-->
    <xsl:choose>
      <xsl:when test="$isAttSet">
        <xs:attributeGroup name="{@name}">
          <xsl:apply-templates mode="generateXsdAttributeDecls"/>
        </xs:attributeGroup>
      </xsl:when>
      <xsl:otherwise>
        <xs:group name="{@name}">         
          <xs:sequence>
            <xsl:apply-templates mode="generateXsdContentModel">
              <xsl:with-param name="isAttSet" as="xs:boolean" select="$isAttSet" tunnel="yes"/>      
            </xsl:apply-templates>
          </xs:sequence>
        </xs:group>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template mode="generateXsdAttributeDecls" match="a:documentation">
    <xs:annotation>
      <xs:documentation>
        <xsl:apply-templates select="." mode="documentation"/>
      </xs:documentation>
    </xs:annotation>
  </xsl:template>
  
  <xsl:template mode="handleDefinitionsForMod" match="rng:element">
    <xs:element name="{@name}">
      <xs:annotation>
        <xs:documentation>
          <xsl:apply-templates select="a:documentation" mode="documentation"/>
        </xs:documentation>
      </xs:annotation>
      <xs:complexType>
        <xs:complexContent>
          <xs:extension base="{@name}.class">
            <xs:attribute ref="class" default="{local:getElementClassValue(.)}"/>
          </xs:extension>
        </xs:complexContent>
      </xs:complexType>
    </xs:element>
    <xs:complexType name="{@name}.class">
      <xsl:if test="rngfunc:isMixedContent(.)">
        <xsl:attribute name="mixed" select="'true'"/>
      </xsl:if>
      <xs:sequence>
        <xs:group ref="{@name}.content"/>
      </xs:sequence>
      <xs:attributeGroup ref="{@name}.attributes"/>
    </xs:complexType>
    
    <xs:group name="{@name}.content">
      <xsl:variable name="contentPatternName" as="xs:string"
        select="concat(@name, '.content')"
      />
      <xsl:apply-templates 
        select="rng:ref[@name = $contentPatternName]" 
        mode="generateXsdContentModel"/>
    </xs:group>
    
    <xs:attributeGroup name="{@name}.attributes">
      <xsl:variable name="attributesPatternName" as="xs:string"
        select="concat(@name, '.attributes')"
      />
      <!-- We only want those attributes defined in the tagname.attributes
           pattern for the element type. The global-atts group is
           an invariant reference and the @class attribute is handled
           separately.
        -->
      <xsl:apply-templates 
        select="../../rng:define[@name = $attributesPatternName]" 
        mode="doElementTypeAttlistGeneration">
        <xsl:with-param name="tagname" select="@name" as="xs:string" tunnel="yes"/>
      </xsl:apply-templates>      
      <xs:attributeGroup ref="global-atts"/>
    </xs:attributeGroup>
  </xsl:template>
  
  <xsl:template match="*" mode="handleDefinitionsForMod" priority="-1">
    <xsl:message> - [WARN] Mode element-decls: Unhandled element <xsl:value-of select="name(..), '/', name(.)"/></xsl:message>
  </xsl:template>

  <!-- ============================
       Mode generateXsdContentModel
       ============================ -->
  
  <xsl:template mode="generateXsdContentModel" match="rng:element/rng:ref" priority="10">
    <!--<xsl:message> + [DEBUG] generateXsdContentModel: rng:ref name="<xsl:value-of select="@name"/>"</xsl:message>-->
    <xsl:variable name="contentPattern" select="key('definesByName', string(@name))"
      as="element(rng:define)*"
    />
    <xsl:apply-templates mode="#current" select="$contentPattern"/>
  </xsl:template>
  
  <xsl:template mode="generateXsdContentModel generateXsdAttributeDecls" match="a:*">
    <!-- Ignore -->
  </xsl:template>
  
  <xsl:template mode="generateXsdContentModel generateXsdAttributeDecls" match="rng:define">
    <xs:sequence>
      <xsl:apply-templates mode="#current"/>
    </xs:sequence>
  </xsl:template>
  
  <xsl:template mode="generateXsdContentModel generateXsdAttributeDecls" match="rng:zeroOrMore">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <xsl:template mode="generateXsdContentModel generateXsdAttributeDecls" match="rng:oneOrMore">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <xsl:template mode="generateXsdContentModel generateXsdAttributeDecls" match="rng:optional">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <xsl:template mode="generateXsdContentModel" match="rng:choice">
    <xs:choice>
      <xsl:apply-templates mode="#current"/>
    </xs:choice>
  </xsl:template>
  
  <xsl:template mode="generateXsdContentModel" match="rng:zeroOrMore/rng:choice" priority="10">
    <xs:choice minOccurs="0" maxOccurs="unbounded">
      <xsl:apply-templates mode="#current"/>
    </xs:choice>
  </xsl:template>
  
  <xsl:template mode="generateXsdContentModel" match="rng:oneOrMore/rng:choice" priority="10">
    <xs:choice minOccurs="1" maxOccurs="unbounded">
      <xsl:apply-templates mode="#current"/>
    </xs:choice>
  </xsl:template>
  
  <xsl:template mode="generateXsdContentModel" match="rng:optional/rng:choice" priority="10">
    <xs:choice minOccurs="0">
      <xsl:apply-templates mode="#current"/>
    </xs:choice>
  </xsl:template>
  
  <xsl:template mode="generateXsdContentModel" match="rng:ref">
     <xs:group ref="{@name}"/>
  </xsl:template>
  <xsl:template mode="generateXsdContentModel" match="rng:ref[@name = 'any']" priority="10">
      <xs:sequence>
				<xs:any processContents="skip"/>
			</xs:sequence>
  </xsl:template>
  
  <xsl:template mode="generateXsdContentModel" match="rng:optional/rng:ref">
     <xs:group ref="{@name}" minOccurs="0"/>
  </xsl:template>
  
  <xsl:template mode="generateXsdContentModel" match="rng:text">
    <!-- Becomes mixed="true" -->
  </xsl:template>

  <xsl:template mode="generateXsdContentModel" match="rng:empty">
    <!-- Empty sequence in XSD -->
  </xsl:template>

  
  <xsl:template mode="generateXsdContentModel" match="*" priority="-1">
    <xsl:message> - [WARN] generateXsdContentModel: Unhandled element <xsl:value-of select="concat(name(..), '/', name(.))"/></xsl:message>
  </xsl:template>
  
  <!-- ==============================
       Mode generateXsdAttributeDecls
       ============================== -->
 
 <xsl:template mode="doElementTypeAttlistGeneration" match="rng:define">
   <!-- This mode handles the .attlist pattern used for each unique 
        element type.
     -->
   <xsl:apply-templates mode="generateXsdAttributeDecls"/>
 </xsl:template>
 
  <xsl:template mode="generateXsdAttributeDecls" match="rng:empty">
    <!-- Do nothing. Result should be an empty xs:attributeGroup element -->
  </xsl:template>

  <xsl:template mode="generateXsdAttributeDecls" match="rng:ref">
    <xs:attributeGroup ref="{@name}"/>
  </xsl:template>

  <xsl:template mode="generateXsdAttributeDecls" match="rng:attribute[matches(@name,'^xml:.+')]"
    priority="100">
    <!-- XML namespace attributes are handled through the xml.xsd module -->
  </xsl:template>

  <xsl:template mode="generateXsdAttributeDecls" match="rng:define/rng:attribute ">
    <!-- NOTE: attributes not declared within rng:optional are required -->
    <!-- FIXME: Handle enumerated attributes correctly -->
    <xs:attribute name="{@name}" use="required">
      <xsl:if test="not(rng:choice)">
        <xsl:attribute name="type" select="'xs:string'"/>
      </xsl:if>
      <xsl:apply-templates mode="#current"/>
    </xs:attribute>
  </xsl:template>
  
  <xsl:template mode="generateXsdAttributeDecls" match="rng:optional/rng:attribute" priority="10">
    <!-- FIXME: Handle enumerated attributes correctly -->
    <xs:attribute name="{@name}">
      <xsl:if test="not(rng:choice | rng:data)">
        <xsl:attribute name="type" select="'xs:string'"/>
      </xsl:if>
      <xsl:apply-templates mode="#current"/>
    </xs:attribute>
  </xsl:template>
  
  <xsl:template mode="generateXsdAttributeDecls" match="rng:data">
    <xsl:variable name="rngType" select="@type" as="xs:string"/>
    <!-- NOTE: DITA base vocabulary only uses ID, NMTOKEN, and CDATA
         types on attributes. IDREF is never used.
      -->
    <xsl:attribute name="type"
      select="if ($rngType = 'ID') then 'xs:ID'
       else if ($rngType = 'NMTOKEN')
         then 'xs:NMTOKEN'
         else 'xs:string'
         "
    />
  </xsl:template>
  
  <xsl:template mode="generateXsdAttributeDecls" match="*" priority="-1">
    <xsl:message> - [WARN] generateXsdAttributeDecls: Unhandled element <xsl:value-of select="concat(name(..), '/', name(.))"/></xsl:message>
  </xsl:template>
  
  <xsl:template mode="generateXsdAttributeDecls" match="rng:choice">
    <xs:simpleType>
      <xs:restriction base="xs:string">
        <!-- Have to exclude annotation elements because you can't
             have annotation directly within xs:restriction 
          -->
        <xsl:apply-templates mode="#current" select="rng:value"/>
      </xs:restriction>
    </xs:simpleType>
  </xsl:template>
  
  <xsl:template mode="generateXsdAttributeDecls" match="rng:value">
    <xs:enumeration value="{normalize-space(.)}">
      <xsl:apply-templates select="following-sibling::*[1][self::a:documentation]" mode="#current"/>
    </xs:enumeration>    
  </xsl:template>
    

  
  <xsl:template match="a:*" mode="generateXsdAttributeDecls">
    <!-- Ignore annotations -->
  </xsl:template>
  
  
  <!-- ==============================
       Mode documentation
       ============================== -->
  
  <xsl:template match="a:documentation" mode="documentation">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <xsl:template  mode="documentation" match="text()">
    <xsl:sequence select="."/>
  </xsl:template>
  
  <xsl:template match="a:documentation//*" mode="documentation" priority="-1">
    <xsl:message> - [WARN] Unhandled element <xsl:value-of select="concat(name(..), '/', name(.))"/> within a:documentation element.</xsl:message>
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <!-- ====================
       Mode header-comment
       ==================== -->

  <xsl:template match="dita:moduleDesc" mode="header-comment">
    <xsl:apply-templates select="dita:headerComment" mode="#current"/>
  </xsl:template>
  
  <xsl:template match="dita:headerComment" mode="header-comment">
    <!-- Note that the header comment is a single string with
         space preserved.
      -->
    <xsl:choose>
      <xsl:when test="$headerCommentStyle = 'comment-per-line'">
        <xsl:analyze-string select="." regex="^.+$" flags="m">
          <xsl:matching-substring>
            <xsl:comment><xsl:value-of select="str:pad(., 61)"/></xsl:comment>
            <xsl:text>&#x0a;</xsl:text>
          </xsl:matching-substring>
          <xsl:non-matching-substring>
            <xsl:if test="normalize-space(.) != ''">
              <xsl:comment><xsl:value-of 
                select="str:pad(., 61)"/></xsl:comment>
              <xsl:text>&#x0a;</xsl:text>
            </xsl:if>
          </xsl:non-matching-substring>
        </xsl:analyze-string>
      </xsl:when>
      <xsl:otherwise>
        <xsl:comment><xsl:value-of select="string(.)"/></xsl:comment>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:function name="local:getElementClassValue" as="xs:string">
    <xsl:param name="elementElem" as="element(rng:element)"/>
    <xsl:variable name="defineName" as="xs:string" 
      select="concat($elementElem/@name, '.attlist')"
    />
    <xsl:variable name="classAtt" as="element(rng:attribute)"
      select="root($elementElem)//rng:define[@name = $defineName]//rng:attribute[@name = 'class']"
    />
    
    <xsl:variable name="classValue" as="xs:string" select="$classAtt/@a:defaultValue"/>
    <xsl:sequence select="$classValue"/>
  </xsl:function>
  
</xsl:stylesheet>