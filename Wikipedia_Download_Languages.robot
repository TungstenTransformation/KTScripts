<?xml version="1.0" encoding="UTF-8" ?>
<object class="Robot" serializationversion="2">
  <prologue>
    <saved-by-versions>
      <version>10.3.1.0</version>
      <version>10.4.0.0</version>
      <version>10.7.0.0</version>
      <version>11.2.0.0</version>
      <version>11.3.0.1</version>
    </saved-by-versions>
    <file-type>robot</file-type>
    <referenced-types>
      <type name="WikiPage"/>
    </referenced-types>
    <triggers/>
    <sub-robots/>
    <device-mappings/>
    <comment>This robot generates a set of training files and a set of test files from wikipedia articles for language classification.
It has 3 inputs
- The project path to the Languages project installed by Document Transformation
- A list of languages to download from wikipedia
- The number of pages to download for each language
</comment>
    <tags>
      <tag>Wikipedia</tag>
      <tag>Classification</tag>
      <tag>Language</tag>
      <tag>CDA</tag>
    </tags>
    <referenced-snippets/>
    <typed-variables>
      <typed-variable name="wikiPage" type-name="WikiPage"/>
    </typed-variables>
    <parameters/>
    <return-variables/>
    <store-in-database-variables>
      <variable name="wikiPage"/>
    </store-in-database-variables>
    <browser-engine>WEBKIT</browser-engine>
  </prologue>
  <property name="variables" class="Variables">
    <object class="Variable" serializationversion="1">
      <property name="name" class="String">ProjectPath</property>
      <property name="initialAssignment" class="InitialVariableAssignment">
        <property name="type" class="SimpleTypeReference" id="0">
          <property name="simpleTypeId" class="Integer">12</property>
        </property>
        <property name="assignments" class="AttributeAssignments">
          <property name="value" class="AttributeAssignment">
            <property name="attributeValue" class="String">C:\Document Transformation\Projects\Languages</property>
            <property name="currentlyAssigned" class="Boolean" id="1">true</property>
            <property name="lastKnownAttributeType" class="java.lang.Class">kapow.robot.plugin.common.domain.StringAttributeType</property>
          </property>
        </property>
      </property>
    </object>
    <object class="Variable" serializationversion="1">
      <property name="name" class="String" id="2">Languages</property>
      <property name="initialAssignment" class="InitialVariableAssignment">
        <property name="type" class="SimpleTypeReference" id="3">
          <property name="simpleTypeId" class="Integer">13</property>
        </property>
        <property name="assignments" class="AttributeAssignments">
          <property name="value" class="AttributeAssignment">
            <property name="attributeValue" class="String">ja (japanese)
ko (korean)
zh (mandarin)
pt (portuguese)
ro (romanian)
ar (arabic)
cs (czech)
da (danish)
nl (dutch)
en (english)
et (estonian)
fi (finnish)
fr (french)
de (german)
el (greek)
hu (hungarian)
is (icelandic)
it (italian)
sl (slovenian)
nb (norwegian)
pl (polnish)
pt (portuguese)
ro (romanian)
ru (russian)
sr (serbian)
es (spanish)
sv (swedish)
tr (turkish)
lt (lithuanian)
lv (latvian)
uk (ukrainian)
bg (bulgarian)
sq (albanian)
bs (bosnian)</property>
            <property name="currentlyAssigned" idref="1"/>
            <property name="lastKnownAttributeType" class="java.lang.Class">kapow.robot.plugin.common.domain.TextAttributeType</property>
          </property>
        </property>
      </property>
    </object>
    <object class="Variable" serializationversion="1">
      <property name="name" class="String" id="4">MaxPages</property>
      <property name="initialAssignment" class="InitialVariableAssignment">
        <property name="type" class="SimpleTypeReference" id="5">
          <property name="simpleTypeId" class="Integer">7</property>
        </property>
        <property name="assignments" class="AttributeAssignments">
          <property name="value" class="AttributeAssignment">
            <property name="attributeValue" class="String">1000</property>
            <property name="currentlyAssigned" idref="1"/>
            <property name="lastKnownAttributeType" class="java.lang.Class">kapow.robot.plugin.common.domain.IntegerAttributeType</property>
          </property>
        </property>
      </property>
    </object>
    <object class="Variable" serializationversion="1">
      <property name="name" class="String" id="6">wikiPage</property>
      <property name="initialAssignment" class="InitialVariableAssignment">
        <property name="type" class="TypeReference" serializationversion="0">
          <property name="typeName" class="String">WikiPage</property>
        </property>
      </property>
    </object>
    <object class="Variable" serializationversion="1">
      <property name="name" class="String" id="7">Text</property>
      <property name="global" idref="1"/>
      <property name="initialAssignment" class="InitialVariableAssignment">
        <property name="type" idref="3"/>
      </property>
    </object>
    <object class="Variable" serializationversion="1">
      <property name="name" class="String" id="8">temp</property>
      <property name="initialAssignment" class="InitialVariableAssignment">
        <property name="type" idref="0"/>
      </property>
    </object>
    <object class="Variable" serializationversion="1">
      <property name="name" class="String">P</property>
      <property name="initialAssignment" class="InitialVariableAssignment">
        <property name="type" idref="5"/>
      </property>
    </object>
  </property>
  <property name="proxyServerConfiguration" class="ProxyServerConfiguration" serializationversion="0"/>
  <property name="httpClientType" class="HttpClientType">
    <property name="enum-name" class="String">WEBKIT</property>
  </property>
  <property name="ntlmAuthentication" class="NTLMAuthenticationType">
    <property name="enum-name" class="String">STANDARD</property>
  </property>
  <property name="usePre96DefaultWaiting" class="Boolean" id="9">false</property>
  <property name="maxWaitForTimeout" class="Integer">10000</property>
  <property name="waitRealTime" idref="9"/>
  <property name="privateHTTPCacheEnabled" idref="1"/>
  <property name="privateHTTPCacheSize" class="Integer">2048</property>
  <property name="comment" class="String">This robot generates a set of training files and a set of test files from wikipedia articles for language classification.
It has 3 inputs
- The project path to the Languages project installed by Document Transformation
- A list of languages to download from wikipedia
- The number of pages to download for each language
</property>
  <property name="tags" class="RobotTagList">
    <object class="RobotTag">
      <property name="tag" class="String">Wikipedia</property>
    </object>
    <object class="RobotTag">
      <property name="tag" class="String">Classification</property>
    </object>
    <object class="RobotTag">
      <property name="tag" class="String">Language</property>
    </object>
    <object class="RobotTag">
      <property name="tag" class="String">CDA</property>
    </object>
  </property>
  <property name="humanProcessingTime">
    <null/>
  </property>
  <property name="executionMode" class="ExecutionMode">
    <property name="enum-name" class="String">DIRECT</property>
  </property>
  <property name="avoidExternalReExecution" idref="9"/>
  <property name="transitionGraph" class="Body">
    <blockBeginStep class="BlockBeginStep" id="10"/>
    <steps class="ArrayList">
      <object class="Try" id="11">
        <property name="comment" class="String">This Try step is not being used as a Try Step. It's being used to hide a "Debug Path", that can be manually triggered start the robot at a particular Wikipedia Page.
</property>
      </object>
      <object class="BranchPoint" id="12"/>
      <object class="Transition" serializationversion="3" id="13">
        <property name="name" class="String">Training Set</property>
        <property name="stepAction" class="AssignVariable" serializationversion="4">
          <property name="stringExpr" class="Expression" serializationversion="1">
            <property name="text" class="String">ProjectPath+"\\samples\\train"</property>
          </property>
          <property name="variable" class="kapow.robot.plugin.common.support.AttributeName2">
            <property name="name" class="String">ProjectPath</property>
          </property>
        </property>
        <property name="elementFinders" class="ElementFinders"/>
        <property name="errorHandler" class="ErrorHandler" serializationversion="0"/>
        <property name="comment">
          <null/>
        </property>
        <property name="enabled" idref="1"/>
        <property name="changedProperties" class="java.util.HashSet">
          <element class="String">name</element>
        </property>
      </object>
      <object class="BranchPoint" id="14"/>
      <object class="Transition" serializationversion="3" id="15">
        <property name="name" class="String">for each language</property>
        <property name="stepAction" class="ForEachTextPart">
          <property name="input" class="kapow.robot.plugin.common.support.expression.multipletype.VariableExpression" serializationversion="2">
            <property name="variable" class="kapow.robot.plugin.common.support.AttributeName2">
              <property name="name" class="String">Languages</property>
            </property>
          </property>
          <property name="delimiter" class="Expression" serializationversion="1">
            <property name="text" class="String">"\n"</property>
          </property>
          <property name="output" class="kapow.robot.plugin.common.support.AttributeName2">
            <property name="name" class="String">wikiPage.Language</property>
          </property>
        </property>
        <property name="elementFinders" class="ElementFinders"/>
        <property name="errorHandler" class="ErrorHandler" serializationversion="0"/>
        <property name="comment">
          <null/>
        </property>
        <property name="enabled" idref="1"/>
        <property name="changedProperties" class="java.util.HashSet">
          <element class="String">name</element>
        </property>
      </object>
      <object class="Transition" serializationversion="3" id="16">
        <property name="name" class="String">DEBUG:only do 5 languages!</property>
        <property name="stepAction" class="TestValue" serializationversion="0">
          <property name="condition" class="Expression" serializationversion="1">
            <property name="text" class="String">iteration()&lt;=10</property>
          </property>
        </property>
        <property name="elementFinders" class="ElementFinders" id="17"/>
        <property name="errorHandler" class="ErrorHandler" serializationversion="0">
          <property name="reportingViaAPI" idref="9"/>
          <property name="reportingViaLog" idref="9"/>
          <property name="controlFlow" class="kapow.robot.robomaker.robot.ControlFlow$BreakLoop"/>
        </property>
        <property name="comment" class="String">disable this step to get all languages</property>
        <property name="enabled" idref="9"/>
        <property name="changedProperties" class="java.util.HashSet">
          <element class="String" id="18">name</element>
        </property>
      </object>
      <object class="Transition" serializationversion="3" id="19">
        <property name="name" class="String">Find Start Page for Language</property>
        <property name="stepAction" class="AssignVariable" serializationversion="4">
          <property name="stringExpr" class="kapow.robot.plugin.common.support.expression.multipletype.StringProcessorsExpression" serializationversion="0">
            <property name="dataConverters" class="DataConverters">
              <element class="GetVariable" serializationversion="2">
                <property name="variable" class="kapow.robot.plugin.common.support.AttributeName2">
                  <property name="name" class="String">wikiPage.Language</property>
                </property>
              </element>
              <element class="Extract2DataConverter">
                <property name="pattern" class="kapow.robot.plugin.common.support.expression.stringexpr.PatternValueStringExpression">
                  <property name="value" class="String">(.*?)\s.*</property>
                </property>
              </element>
              <element class="EvaluateExpression" serializationversion="0">
                <property name="expression" class="String">"https://"+INPUT+".wikipedia.org/wiki/"</property>
              </element>
            </property>
          </property>
          <property name="variable" class="kapow.robot.plugin.common.support.AttributeName2">
            <property name="name" class="String">wikiPage.Address</property>
          </property>
        </property>
        <property name="elementFinders" idref="17"/>
        <property name="errorHandler" class="ErrorHandler" serializationversion="0"/>
        <property name="comment">
          <null/>
        </property>
        <property name="enabled" idref="1"/>
        <property name="changedProperties" class="java.util.HashSet">
          <element idref="18"/>
        </property>
      </object>
      <object class="Transition" serializationversion="3" id="20">
        <property name="name" class="String">title of page</property>
        <property name="stepAction" class="AssignVariable" serializationversion="4">
          <property name="stringExpr" class="kapow.robot.plugin.common.support.expression.stringexpr.ValueStringExpression">
            <property name="value" class="String">Main</property>
          </property>
          <property name="variable" class="kapow.robot.plugin.common.support.AttributeName2">
            <property name="name" class="String">wikiPage.Title</property>
          </property>
        </property>
        <property name="elementFinders" class="ElementFinders"/>
        <property name="errorHandler" class="ErrorHandler" serializationversion="0"/>
        <property name="comment">
          <null/>
        </property>
        <property name="enabled" idref="1"/>
        <property name="changedProperties" class="java.util.HashSet">
          <element class="String">name</element>
        </property>
      </object>
      <object class="Try" id="21"/>
      <object class="Transition" serializationversion="3" id="22">
        <property name="name" class="String">old page?</property>
        <property name="stepAction" class="FindInDatabase" serializationversion="0">
          <property name="variableName" class="kapow.robot.plugin.common.support.VariableName">
            <property name="name" class="String">wikiPage</property>
          </property>
          <property name="key" class="kapow.robot.plugin.common.support.expression.multipletype.VariableExpression" serializationversion="2">
            <property name="variable" class="kapow.robot.plugin.common.support.AttributeName2">
              <property name="name" class="String">wikiPage.Address</property>
            </property>
          </property>
        </property>
        <property name="elementFinders" class="ElementFinders"/>
        <property name="errorHandler" class="ErrorHandler" serializationversion="0">
          <property name="reportingViaAPI" idref="9"/>
          <property name="reportingViaLog" idref="9"/>
          <property name="controlFlow" class="kapow.robot.robomaker.robot.ControlFlow$NextAlternative"/>
        </property>
        <property name="comment">
          <null/>
        </property>
        <property name="enabled" idref="1"/>
        <property name="changedProperties" class="java.util.HashSet">
          <element idref="18"/>
        </property>
      </object>
      <object class="End" id="23"/>
      <object class="Transition" serializationversion="3" id="24">
        <property name="name" class="String">Assign Temp</property>
        <property name="stepAction" class="AssignVariable" serializationversion="4">
          <property name="stringExpr" class="kapow.robot.plugin.common.support.expression.multipletype.StringProcessorsExpression" serializationversion="0">
            <property name="dataConverters" class="DataConverters">
              <element class="GetVariable" serializationversion="2">
                <property name="variable" class="kapow.robot.plugin.common.support.AttributeName2">
                  <property name="name" class="String">wikiPage.Address</property>
                </property>
              </element>
              <element class="Extract2DataConverter">
                <property name="pattern" class="kapow.robot.plugin.common.support.expression.stringexpr.PatternValueStringExpression">
                  <property name="value" class="String">.*/(.*)</property>
                </property>
              </element>
              <element class="URLDecode"/>
            </property>
          </property>
          <property name="variable" class="kapow.robot.plugin.common.support.AttributeName2">
            <property name="name" idref="8"/>
          </property>
        </property>
        <property name="elementFinders" class="ElementFinders" id="25"/>
        <property name="errorHandler" class="ErrorHandler" serializationversion="0">
          <property name="reportingViaAPI" idref="9"/>
          <property name="reportingViaLog" idref="9"/>
          <property name="controlFlow" class="kapow.robot.robomaker.robot.ControlFlow$NextIteration"/>
        </property>
        <property name="comment">
          <null/>
        </property>
        <property name="enabled" idref="1"/>
        <property name="changedProperties" class="java.util.HashSet"/>
      </object>
      <object class="Transition" serializationversion="3" id="26">
        <property name="name" class="String">Assign Address</property>
        <property name="stepAction" class="AssignVariable" serializationversion="4">
          <property name="stringExpr" class="kapow.robot.plugin.common.support.expression.multipletype.StringProcessorsExpression" serializationversion="0">
            <property name="dataConverters" class="DataConverters">
              <element class="GetVariable" serializationversion="2">
                <property name="variable" class="kapow.robot.plugin.common.support.AttributeName2">
                  <property name="name" class="String">wikiPage.Address</property>
                </property>
              </element>
              <element class="Extract2DataConverter">
                <property name="pattern" class="kapow.robot.plugin.common.support.expression.stringexpr.PatternValueStringExpression">
                  <property name="value" class="String">(.*/).*</property>
                </property>
              </element>
              <element class="EvaluateExpression" serializationversion="0">
                <property name="expression" class="String">INPUT+temp</property>
              </element>
            </property>
          </property>
          <property name="variable" class="kapow.robot.plugin.common.support.AttributeName2">
            <property name="name" class="String">wikiPage.Address</property>
          </property>
        </property>
        <property name="elementFinders" idref="25"/>
        <property name="errorHandler" class="ErrorHandler" serializationversion="0"/>
        <property name="comment">
          <null/>
        </property>
        <property name="enabled" idref="1"/>
        <property name="changedProperties" class="java.util.HashSet"/>
      </object>
      <object class="Transition" serializationversion="3" id="27">
        <property name="name" class="String">URL&lt;255?</property>
        <property name="stepAction" class="TestValue" serializationversion="0">
          <property name="condition" class="Expression" serializationversion="1">
            <property name="text" class="String">length(wikiPage.Address)&lt;255</property>
          </property>
        </property>
        <property name="elementFinders" idref="25"/>
        <property name="errorHandler" class="ErrorHandler" serializationversion="0">
          <property name="reportingViaAPI" idref="9"/>
          <property name="reportingViaLog" idref="9"/>
          <property name="controlFlow" class="kapow.robot.robomaker.robot.ControlFlow$NextIteration"/>
        </property>
        <property name="comment">
          <null/>
        </property>
        <property name="enabled" idref="1"/>
        <property name="changedProperties" class="java.util.HashSet">
          <element class="String">name</element>
        </property>
      </object>
      <object class="Transition" serializationversion="3" id="28">
        <property name="name" class="String" id="29">Store in Database</property>
        <property name="stepAction" class="StoreInDatabase" serializationversion="0">
          <property name="variableName" class="kapow.robot.plugin.common.support.VariableName">
            <property name="name" class="String">wikiPage</property>
          </property>
          <property name="key" class="kapow.robot.plugin.common.support.expression.multipletype.VariableExpression" serializationversion="2">
            <property name="variable" class="kapow.robot.plugin.common.support.AttributeName2">
              <property name="name" class="String">wikiPage.Address</property>
            </property>
          </property>
        </property>
        <property name="elementFinders" class="ElementFinders"/>
        <property name="errorHandler" class="ErrorHandler" serializationversion="0">
          <property name="reportingViaAPI" idref="9"/>
          <property name="reportingViaLog" idref="9"/>
          <property name="controlFlow" class="kapow.robot.robomaker.robot.ControlFlow$NextIteration"/>
        </property>
        <property name="comment">
          <null/>
        </property>
        <property name="enabled" idref="1"/>
        <property name="changedProperties" class="java.util.HashSet"/>
      </object>
      <object class="End" id="30"/>
      <object class="Transition" serializationversion="3" id="31">
        <property name="name" class="String">Repeat</property>
        <property name="stepAction" class="Repeat"/>
        <property name="elementFinders" idref="17"/>
        <property name="errorHandler" class="ErrorHandler" serializationversion="0"/>
        <property name="comment">
          <null/>
        </property>
        <property name="enabled" idref="1"/>
        <property name="changedProperties" class="java.util.HashSet"/>
      </object>
      <object class="Transition" serializationversion="3" id="32">
        <property name="name" class="String">get random unread page</property>
        <property name="stepAction" class="QueryDatabase2" serializationversion="1">
          <property name="sql" class="String">"SELECT language,objectkey FROM wikiPage
where processed='n'
order by random()
fetch first "+20+" rows only
"</property>
          <property name="columnAttributeMappings" class="kapow.robot.plugin.common.support.database.ColumnAttributeMappings">
            <object class="kapow.robot.plugin.common.support.database.ColumnAttributeMapping">
              <property name="columnName" class="String">objectkey</property>
              <property name="attributeName" class="kapow.robot.plugin.common.support.AttributeName2">
                <property name="name" class="String">wikiPage.Address</property>
              </property>
            </object>
            <object class="kapow.robot.plugin.common.support.database.ColumnAttributeMapping">
              <property name="columnName" class="String">LANGUAGE</property>
              <property name="attributeName" class="kapow.robot.plugin.common.support.AttributeName2">
                <property name="name" class="String">wikiPage.Language</property>
              </property>
            </object>
          </property>
        </property>
        <property name="elementFinders" class="ElementFinders"/>
        <property name="errorHandler" class="ErrorHandler" serializationversion="0">
          <property name="reportingViaAPI" idref="9"/>
          <property name="reportingViaLog" idref="9"/>
          <property name="controlFlow" class="kapow.robot.robomaker.robot.ControlFlow$BreakLoop"/>
        </property>
        <property name="comment">
          <null/>
        </property>
        <property name="enabled" idref="1"/>
        <property name="changedProperties" class="java.util.HashSet">
          <element class="String">name</element>
        </property>
      </object>
      <object class="Transition" serializationversion="3" id="33">
        <property name="name" class="String">Next</property>
        <property name="stepAction" class="Next"/>
        <property name="elementFinders" class="ElementFinders"/>
        <property name="errorHandler" class="ErrorHandler" serializationversion="0"/>
        <property name="comment">
          <null/>
        </property>
        <property name="enabled" idref="1"/>
        <property name="changedProperties" class="java.util.HashSet"/>
      </object>
      <object class="Transition" serializationversion="3" id="34">
        <property name="name" class="String">how many pages needed for this language?</property>
        <property name="stepAction" class="QueryDatabase2" serializationversion="1">
          <property name="sql" class="String">"
SELECT ("+MaxPages+"-count(*)) as Count FROM wikiPage
where processed='y' and filename is not null
and language='"+wikiPage.Language+"'"</property>
          <property name="columnAttributeMappings" class="kapow.robot.plugin.common.support.database.ColumnAttributeMappings">
            <object class="kapow.robot.plugin.common.support.database.ColumnAttributeMapping">
              <property name="columnName" class="String">count</property>
              <property name="attributeName" class="kapow.robot.plugin.common.support.AttributeName2">
                <property name="name" idref="4"/>
              </property>
            </object>
          </property>
        </property>
        <property name="elementFinders" class="ElementFinders"/>
        <property name="errorHandler" class="ErrorHandler" serializationversion="0"/>
        <property name="comment">
          <null/>
        </property>
        <property name="enabled" idref="1"/>
        <property name="changedProperties" class="java.util.HashSet">
          <element class="String">name</element>
        </property>
      </object>
      <object class="Try" id="35"/>
      <object class="Transition" serializationversion="3" id="36">
        <property name="name" class="String">Need more links?</property>
        <property name="stepAction" class="TestValue" serializationversion="0">
          <property name="condition" class="Expression" serializationversion="1">
            <property name="text" class="String">MaxPages&gt;0</property>
          </property>
        </property>
        <property name="elementFinders" class="ElementFinders"/>
        <property name="errorHandler" class="ErrorHandler" serializationversion="0">
          <property name="reportingViaAPI" idref="9"/>
          <property name="reportingViaLog" idref="9"/>
          <property name="controlFlow" class="kapow.robot.robomaker.robot.ControlFlow$NextAlternative"/>
        </property>
        <property name="comment">
          <null/>
        </property>
        <property name="enabled" idref="1"/>
        <property name="changedProperties" class="java.util.HashSet">
          <element class="String">name</element>
        </property>
      </object>
      <object class="Transition" serializationversion="3" id="37">
        <property name="name" class="String">Find in Database</property>
        <property name="stepAction" class="FindInDatabase" serializationversion="0">
          <property name="variableName" class="kapow.robot.plugin.common.support.VariableName">
            <property name="name" idref="6"/>
          </property>
          <property name="key" class="kapow.robot.plugin.common.support.expression.multipletype.VariableExpression" serializationversion="2">
            <property name="variable" class="kapow.robot.plugin.common.support.AttributeName2">
              <property name="name" class="String">wikiPage.Address</property>
            </property>
          </property>
        </property>
        <property name="elementFinders" idref="17"/>
        <property name="errorHandler" class="ErrorHandler" serializationversion="0"/>
        <property name="comment">
          <null/>
        </property>
        <property name="enabled" idref="1"/>
        <property name="changedProperties" class="java.util.HashSet"/>
      </object>
      <object class="Try" id="38"/>
      <object class="Transition" serializationversion="3" id="39">
        <property name="name" class="String">open page</property>
        <property name="stepAction" class="LoadPage2">
          <property name="urlProvider" class="kapow.robot.plugin.common.stepaction.urlprovider2.AttributeURLProvider2" serializationversion="1">
            <property name="variable" class="kapow.robot.plugin.common.support.AttributeName2">
              <property name="name" class="String">wikiPage.Address</property>
            </property>
          </property>
          <property name="waitCriteria" class="WaitCriteria">
            <object class="HTMLElementFoundWaitCriterion">
              <property name="finder" class="DefaultNamedElementUnawareDOMElementFinder" serializationversion="4">
                <property name="frameRecursive" idref="1"/>
                <property name="nodePath" class="kapow.robot.plugin.common.support.expression.stringexpr.ValueStringExpression">
                  <property name="value" class="String">*.a</property>
                </property>
                <property name="nodePattern" class="kapow.robot.plugin.common.support.expression.stringexpr.PatternValueStringExpression">
                  <property name="value" class="String">.*Privacy policy.*</property>
                </property>
              </property>
            </object>
            <object class="HTMLElementFoundWaitCriterion">
              <property name="finder" class="DefaultNamedElementUnawareDOMElementFinder" serializationversion="4">
                <property name="frameRecursive" idref="1"/>
                <property name="nodePath" class="kapow.robot.plugin.common.support.expression.stringexpr.ValueStringExpression">
                  <property name="value" class="String">.*.a</property>
                </property>
                <property name="attributeName" class="String">class</property>
                <property name="attributeValue" class="kapow.robot.plugin.common.support.predicate.unary.string.FixedStringPredicate">
                  <property name="text" class="String">extiw</property>
                </property>
                <property name="nodePattern" class="kapow.robot.plugin.common.support.expression.stringexpr.PatternValueStringExpression">
                  <property name="value" class="String">Privacy policy</property>
                </property>
              </property>
            </object>
          </property>
          <property name="browserConfigurationSpecification" class="BrowserConfigurationSpecificationWebKit" serializationversion="27">
            <property name="SSLUsage" class="com.kapowtech.net.ssl.SSLUsage" id="40">
              <property name="enum-name" class="String">TLS_Insecure</property>
            </property>
            <property name="followMetaRedirects" idref="9"/>
            <property name="loadFrames" idref="9"/>
            <property name="outputPageIfTimeoutEnabled" idref="9"/>
            <property name="blockedUrlPatterns" class="String">.*//upload.*
.*-adspace.*
.*&amp;adspace=.*
.*=viewAdJs.*
.*&amp;affiliate=.*
.*&amp;ClientType=.*&amp;AdID=.*
.*&amp;google_adpage=.*
.*\?adtype=.*
.*\?affiliate.*
.*\?getad=&amp;.*
.*\?resizediv=.*promo=.*
.*\?showbanner=.*
.*_ad\.aspx.*
.*_adbrite.*
.*_adfunction.*
.*_ads/.*
.*_ads\.php\?.*
.*_adspace.*
.*_advertisement.*\.gif.*
.*_banner_ad.*
.*_bannerid.*random.*
.*_companionad\..*
.*_skyscraper_.*
.*_videoad\..*
.*adaffiliate.*
.*AdIFrame.*
.*admentor.*
.*ADTECH;cookie=.*
.*ads\.sv\.publicus\..*
.*adsfac\.net.*
.*adwords\.google\..*imgad.*
.*affiliatebrand\..*
.*audienceprofiler\..*
.*aurora-.*marketing\.co.*
.*banner-ad.*
.*bannerad.*
.*BannerMangement.*
.*banners&amp;id=.*
.*blog\.tmcnet\..*/overlib\.js.*
.*brandcentral\..*
.*Click.*Advertiser.*
.*clicktag=.*/ad.*
.*content\.search.*
.*adserving\.cpxinteractive.*
.*cubics\.com/.*
.*dbbsrv\.com.*
.*dgmaustralia\..*
.*download-door\.search\.com/search.*
.*dynamicad\..*
.*earthlink.*/promos.*
.*eas\.blocket\..*
.*engine\.awaps\.net/.*
.*exitexplosion\..*/exit\.js.*
.*expedia_ad\..*
.*faireagle\.com.*
.*favinfo\.com/ad\..*
.*gamesbanner\.net/.*
.*geocities\.com/js_source/.*
.*google\.com.*/promo_.*
.*hera\.hardocp\..*
.*imageshack.*tagworld.*
.*interclick\..*
.*js\.worthathousandwords\..*
.*js2\.yimg\..*_popup_.*
.*kanoodle.*
.*leftsidead\..*
.*link_ads.*
.*maps\.google\.com.*.*mediacorpsingapore.*
.*medrx\.sensis\.com\.au/content/.*
.*nebuad\.com.*
.*netspiderads.*
.*network\.ninemsn\..*/share/.*
.*nbjmp\.com/.*
.*openbanner.*
.*page\.grabclick\..*
.*phpadsnew.*
.*popinads\..*
.*popunder.*
.*popup_ad\..*
.*precisionclick\..*
.*pro-market\..*
.*promopop.*
.*ptnrcontent.*
.*publicidad.*
.*quigo\.com.*
.*rad\.live\.com/ADSAdClient.*
.*richmedia\..*yimg\..*
.*rightsidead\..*
.*s\.trigami\..*
.*space\.com/.*interstitial_space\.js.*
.*sponslink.*
.*sponsor\.gif.*
.*sponsorads.*
.*sponsored_links.*
.*sponsors.*banner.*
.*sys-con\.com/common/.*
.*targetpoint\.com.*
.*textlink-ads\..*
.*themis\.yahoo\..*
.*vs20060817\.com/.*
.*worsethanfailure\..*/Tizes/.*
.*www\.cb\.cl/.*banner.*
.*www\.ad\.tomshardware\..*=banner.*
.*xcelsiusadserver\..*
.*yceml\.net.*
.*\.1100i\.com/.*
.*\.188server\..*
.*\.2mdn\.net/.*
.*\.360ads\..*
.*\.43plc\.com.*
.*\.about\.com/0/.*
.*\.accuserveadsystem\..*
.*\.acronym\.com/.*
.*\.ad\.tomshardware\.com/.*
.*\.ad\.twitchguru\..*
.*\.ad-flow\..*
.*\.ad20\.net/.*
.*\.ad4cash\..*
.*\.adaction\..*
.*\.adbard\.net/ab.*
.*\.adblade\.com/.*
.*\.adbrite\.com/mb/.*
.*\.adbureau\..*
.*\.adbutler\..*
.*\.adcentriconline\..*
.*\.adchap\..*
.*\.adecn\.com/.*
.*\.adengage\..*
.*\.adf01\.net/.*
.*\.adfusion\..*
.*\.adgardener\..*
.*\.adgine\..*
.*\.adgroups\..*
.*\.adhese\..*
.*\.adicate\..*
.*\.adition\.com/.*
.*\.adinterax\..*
.*\.adireland\..*
.*\.adjuggler\..*
.*\.admarketplace\..*
.*\.adnet\.biz.*
.*\.adlink\.net.*
.*\.adnet\.ru.*
.*\.adocean\..*
.*\.adoperator\..*
.*\.adotube\.com/overstreamPlatform/.*
.*\.adpark\..*
.*\.adpinion\..*
.*\.adsdk\.com/.*
.*\.adserver\..*\?.*
.*\.adservinginternational\..*
.*\.adsforindians\..*
.*\.adshopping\..*
.*\.adshuffle\..*
.*\.adsmarket\..*
.*\.adsonar\..*
.*\.adspeed\..*
.*\.adtext\..*
.*\.adtmedia\..*
.*\.adtology3\..*
.*\.adtoma\.com/.*
.*\.adtrgt\..*
.*\.adultadworld\..*
.*\.adultfriendfinder\.com/banners/.*
.*\.adverserve\..*
.*\.advertarium\..*
.*\.adverticum\.net/.*
.*\.advertising\..*
.*\.advertising-department\.com.*\.php\?.*
.*\.advertlets\..*
.*\.advertserve\..*
.*\.adviva\..*
.*\.adxpower\..*
.*\.agentcenters\..*
.*\.afcyhf\..*
.*\.affiliate\..*
.*\.affiliatefuel\..*
.*\.affiliatefuture\..*
.*\.affiliproducts\.com/showProducts\..*
.*\.affiliatesensor\..*
.*\.affilimatch\..*
.*\.aim4media\..*
.*\.akamai\..*sponsor.*
.*\.alphagodaddy\..*
.*\.anrdoezrs\..*
.*\.arcadebanners\..*
.*\.as5000\..*
.*\.ase\.cc/.*
.*\.assoc-amazon\..*
.*\.atdmt\.com/.*
.*\.atwola\..*
.*\.auspipe\..*
.*\.avads\.co\.uk/.*
.*\.awin1\.com.*
.*\.awltovhc\..*
.*\.axill\.com/.*
.*\.azads\.com/.*
.*\.azjmp\.com/.*
.*\.azoogleads\..*
.*\.bannerbank\.ru/.*
.*\.bannerconnect\..*
.*\.bannersmania\..*
.*\.bbc\.co\.uk/.*/vs\.js.*
.*\.begun\.ru/.*
.*\.belointeractive\..*
.*\.bestofferdirect\..*
.*\.bidvertiser\..*
.*\.bimedia\.net/video/.*
.*\.blogads\.com/.*
.*\.bloggerads\..*
.*\.bluestreak\..*
.*\.bravenetmedianetwork\..*
.*\.bravenet\..*/rover/.*
.*\.bridgetrack\..*
.*\.btrll\.com/.*
.*\.burstnet\..*
.*\.c-on-text\..*
.*\.c8\.net\.ua/.*
.*\.casalemedia\..*
.*\.cc-dt\.com/.*
.*\.centralmediaserver\..*
.*\.cgecwm\.org/.*
.*\.checkm8\..*
.*\.checkmystats\..*
.*\.chitika\..*
.*\.ciao\.co\.uk/load_file\.php\?.*
.*\.cjt1\.net.*
.*\.clash-media\..*
.*\.claxonmedia\..*
.*\.clickad\..*
.*\.clickbooth.*
.*\.clickexperts\..*
.*\.clickintext\..*
.*\.clickthrucash\..*
.*\.clixgalore\..*
.*\.co\.uk/ads\.pl.*
.*\.codeproject\..*/ServeImg\..*
.*\.cogsdigital\..*
.*\.com/ads\.pl.*
.*\.com/sideads.*
.*\.com/topads.*
.*\.commission-junction\..*
.*\.commissionmonster\..*
.*\.connextra\..*
.*\.contextuads\..*
.*\.contextweb\..*
.*\.cpaclicks.*
.*\.cpays\.com/.*
.*\.cpmstar\..*
.*\.cpuim\.com/.*
.*\.crashextads\..*
.*\.crispads\..*
.*\.decisionmark\..*
.*\.decisionnews\..*
.*\.deepmetrix\..*
.*\.dl-rms\.com/.*
.*\.domainsponsor\..*
.*\.doubleclick\.net/adi/.*
.*\.doubleclick\.net/adj/.*
.*\.doubleclick\.net/pfadx/.*
.*\.doubleclick\.net/.*;cue=pre;.*
.*\.dpbolvw\..*
.*\.dynw\.com/banner.*
.*\.ebayrtm\.com/rtm\?rtmcmd&amp;a=json.*
.*\.ebaystatic\./adserver.*
.*\.edge\.ru4\..*
.*\.egotastic\.com/obp-.*
.*\.emediate\..*
.*\.etology\..*
.*\.euroclick\..*
.*\.exponential\..*
.*\.eyereturn\..*
.*\.eyewonder\..*
.*\.falkag\..*
.*\.fastclick\..*
.*\.feedburner\.com/~a/.*
.*\.filefront\..*/fnOverlay\.js.*
.*\.fimserve\..*
.*\.firstadsolution\..*
.*\.firstlightera\.com/era/.*
.*\.fixionmedia\..*
.*\.fmpub\.net/.*
.*\.forrestersurveys\..*
.*\.fluxads\..*
.*\.flyordie\.com/games/free/b/.*--\?p=.*
.*\.friendlyduck\..*
.*\.ftjcfx\..*
.*\.funklicks\..*
.*\.fwmrm\.net/.*\.flv.*
.*\.fwmrm\.net/.*\.swf.*
.*\.g\.akamai\..*/ads\..*
.*\.game-advertising-online\..*
.*\.gamecetera\..*
.*\.gamersbanner\..*
.*\.geopromos\..*
.*\.gestionpub\..*
.*\.getprice\.com\.au/searchwidget\.aspx\?.*
.*\.gklmedia\..*
.*\.go\.com/.*ads\.js.*
.*\.go\.globaladsales\.com/.*
.*/googleads\.g\.doubleclick\.net/pagead/.*
.*\.googleadservices\..*
.*\.grabmyads\..*
.*\.gumgum\..*/ggv2\.js.*
.*\.henwo\.com/.*
.*\.hit-now\..*
.*\.hosticanaffiliate\..*
.*\.httpool\..*
.*\.hypemakers\..*
.*\.hypervre\..*
.*\.ibatom\..*/syndication/.*
.*\.ic-live\..*
.*\.icdirect\..*
.*\.idg\.com\.au/images/.*_promo.*
.*\.imagesatlantic\..*
.*\.imedia\.co\.il/.*
.*\.infinite-ads\..*
.*\.imglt\.com/.*
.*\.impresionesweb\..*
.*\.indiads\..*
.*\.industrybrains\..*
.*\.inetinteractive\..*
.*\.infocious\..*
.*\.intellitxt\..*
.*\.interpolls\..*
.*\.jdoqocy\..*
.*\.jumboaffiliates\..*
.*\.jydesign\..*
.*\.ketoo\.com/.*
.*\.klipmart\..*
.*\.kontera\..*
.*\.kqzyfj\..*
.*\.leadacceptor\..*
.*\.lduhtrp\..*
.*\.lightningcast\..*
.*\.linkads\..*\?.*
.*\.linkexchange\..*
.*\.linkworth\..*
.*\.litres\.ru/static/banner/.*
.*\.ltassrv\..*
.*\.main\.ebayrtm\.com/rtm\?RtmCmd&amp;a=inline&amp;.*
.*\.maxserving\..*
.*\.mb01\.com/.*
.*\.mbn\.com\.ua/.*
.*\.mediagridwork\.com/mx\.js.*
.*\.medialand\.ru/.*
.*\.mediaonenetwork\..*
.*\.mediaplex\..*
.*\.mediatarget\..*
.*\.mediavantage\..*
.*\.megaclick\.com/.*
.*\.mercuras\..*
.*\.metaffiliation\..*
.*\.microsoftaffiliates\..*\.aspx\?.*
.*\.mirago\.com/.*
.*\.miva\.com/.*
.*\.mochiads\.com/srv/.*
.*\.mootermedia\..*
.*\.msn\.com/\?adunitid.*
.*\.myway\.com/gca_iframe\..*
.*\.neoseeker\.com/.*_pc\.html.*
.*\.net3media\..*
.*\.netavenir\..*
.*\.newanglemedia\.com/clients/.*
.*\.news\.com\.au/.*-promo.*
.*\.newsadstream\..*
.*\.northmay\..*
.*\.ng/.*&amp;affiliate=.*
.*\.nwsource\..*/adv\.gif.*
.*\.nyadmcncserve-.*
.*\.obibanners\..*
.*\.othersonline\.com/partner/scripts/.*\?.*
.*\.onenetworkdirect\..*
.*\.openx\.org/a.*\.php.*
.*\.overture\..*
.*\.oxado\.com/.*
.*\.pc-ads\.com/.*
.*\.perfb\.com.*
.*\.pgpartner\..*
.*\.pheedo\..*/img\.phdo\?.*
.*\.php\?bannerid.*
.*\.php\?adclass.*
.*\.platinumadvertisement\..*
.*\.playertraffic\..*
.*\.pointroll\..*
.*\.predictad\..*
.*\.pricegrabber\..*
.*\.pricespy\.co\.nz/adds/.*
.*\.primaryads\..*
.*\.pro-advertising\..*
.*\.probannerswap\..*
.*\.profitpeelers\..*
.*\.projectwonderful\..*
.*\.proximic\.com/js/widget\.js.*
.*\.pulse360\..*
.*\.qksrv\.net/.*
.*\.qksz\.net/.*
.*\.questionmarket\..*
.*\.questus\.com/.*
.*\.realmatch\.com/Widgets/JS/.*
.*\.revresda\..*
.*\.rmxads\..*
.*\.rottentomatoes\..*size=.*x.*&amp;dechannel.*
.*\.rovion\..*\?AffID=.*
.*\.rwpads\..*
.*\.scanscout\..*
.*\.sevenload\.com/.*/endscreen\.swf.*
.*\.shareasale\..*
.*\.shareresults\..*
.*\.smartadserver\..*
.*\.smarttargetting\..*
.*\.snap\.com/.*
.*\.snopes\.com/.*/.*ad.*
.*\.socialmedia\.com/.*
.*\.sonnerie\..*
.*\.space\.com/promo/.*
.*\.sparkstudios\..*
.*\.specificclick\..*
.*\.specificmedia\..*
.*\.speedsuccess\.net/.*
.*\.sponsorpalace\..*
.*\.spotplex\..*widget.*
.*\.srtk\.net/.*
.*\.sta-ads\..*
.*\.survey-poll\..*
.*\.swf\?clickTag=.*
.*\.tacoda\..*
.*\.targetnet\..*
.*\.thebigchair\.com\.au/egnonline/.*
.*\.tiser\.com.*
.*\.tkqlhce\..*
.*\.total-media\.net/.*
.*\.tqlkg\.com.*
.*\.tradedoubler\..*
.*\.trafficmasterz\..*
.*\.trafic\..*
.*\.tremormedia\..*/AdManager@domain=~africam\.com.*
.*\.tribalfusion\..*
.*\.twinplan\.com/AF_.*
.*\.typepad\.com/sponsors/.*
.*\.tyroo\.com.*
.*\.uimserv\.net/.*
.*\.unicast\..*
.*\.universalhub\.com/bban/.*
.*\.usercash\.com/.*
.*\.utarget\..*
.*\.valuead\..*
.*\.valueclick\..*
.*\.vibrantmedia\..*
.*\.videoegg\.com/.*/init\.js\?.*
.*\.videosift\.com/bnr\.php\?.*
.*\.visitorglobe\..*record.*
.*\.vpico\.com/.*
.*\.webads\.co\.nz.*
.*\.webmasterplan\..*
.*\.widgetbucks\..*
.*\.worlddatinghere\..*
.*\.xchangebanners\..*
.*\.y\.megaclick\..*
.*\.yahoo\.com/ads\?.*=mrec_ad&amp;.*
.*\.yimg\.com/adv/.*
.*\.yimg\.com/.*/fairfax/.*
.*\.ytimg\.com/yt/swf/ad-.*\.swf.*
.*\.zanox\.com/.*
.*\.zangocash\..*/detectenvironment.*
.*\.zeads\.com/.*
.*\.zedo\.com/.*
.*\.zoomdirect\.com\.au/.*
.*/63\.225\.61\..*
.*/64\.73\.24\.44.*
.*/207\.67\.9\.41/.*
.*/213\.239\.222\.7/ad/.*
.*/217\.15\.94\.117.*
.*/468x60/.*
.*/\.adserv/.*
.*/a\.clearlightdigital\..*
.*/a\.collective-media\.net/.*
.*/a\.kerg\.net/.*
.*/a\.lakequincy\..*
.*/ab\.vcmedia\..*
.*/abmw\.aspx.*
.*/ad\.doubleclick\.net/ad/.*
.*/ad/code.*
.*/ad/view/.*
.*/ad\.asp\?.*
.*/ad\.aspx\?.*
.*/ad2\.aspx\?.*
.*/ad\.php\?.*
.*/ad/frame.*
.*/ad/header_.*
.*/ad/mercury.*
.*/ad/.*promo.*
.*/ad/serve.*
.*/ad/sponsors/.*
.*/ad/textlinks/.*
.*/ad_.*\.gif.*
.*/ad_.*
.*/ad_functions.*
.*/ad_insert\..*
.*/ad_manager\.js.*
.*/ad_refresher\..*
.*/ad_wrapper.*
.*/ad-frame\..*
.*/ad2games\..*
.*/adbanner.*
.*/adbrite.*
.*/adbrite\..*
.*/adclick.*
.*/adcode\.js.*
.*/adconfig/.*
.*/adconfig\.xml\?.*
.*/adcontent\..*
.*/adcycle/.*
.*/addyn.*
.*/adengage_.*
.*/adf\.cgi\?.*
.*/adfetch\?.*
.*/adframe\..*
.*/adframe_.*
.*/adfshow\?.*
.*/adgraphics/.*
.*/adheader.*
.*/adhoc/js/swfobject\.js.*
.*/adiframe/.*
.*/AdIFrame\..*
.*/adimages/.*
.*/adfunction.*
.*/adimage\..*
.*/adinsert\..*
.*/adjs\.php\?.*
.*/adjsmp\.php\?.*
.*/adlabel.*
.*/adlinks\.js.*
.*/adman/www/.*
.*/admanagement/.*
.*/admanager.*
.*/admatch-syndication\..*
.*/admedia\..*
.*/adn\.fusionads\..*
.*/adnetwork\..*
.*/adpage\..*
.*/adpeeps/.*
.*/adpeeps\.php.*
.*/Adplayer/.*
.*/adproducts/.*
.*/adproxy/.*
.*/adRelated\..*
.*/adrevolver/.*
.*/adroot/.*
.*/adrot\.js.*
.*/adserver/.*
.*/adsreporting/.*
.*/ads\.htm.*
.*/ads\.php\?.*
.*/ads_iframe\..*
.*/ads_reporting/.*
.*/ads_v2\.js.*
.*/ads_yahoo\..*
.*/ads.*\.php.*
.*/Ads-Leader.*
.*/Ads-Rec.*
.*/Ads-Sky.*
.*/ads2\.php\?.*
.*/ads2/.*
.*/ADSAdClient31\.dll\?GetAd\?PG=M.*
.*/adscript.*
.*/adsense_.*
.*/adsense\..*
.*/adserv.*/delivery/.*
.*/Adserver\?.*
.*/adServer\..*\?.*
.*/adsfolder/.*
.*/adshow\?.*
.*/AdsIframe/.*
.*/adsimage/.*
.*/AdsInclude\.js.*
.*/AdsManager/.*
.*/adsmanagement/.*\?.*
.*/adspace.*
.*/adspro/.*
.*/adsonar\..*
.*/adSwap\.js.*
.*/adsyndication\..*
.*/adtags/.*
.*/ADTECH;.*
.*/adtext\..*
.*/adtext_.*
.*/adtraff\..*
.*/adtype\.php\?.*
.*/advert_.*
.*/advert/ms.*
.*/adverti.*
.*/advertising/.*
.*/advertpro/.*
.*/adverts_.*
.*/adverts/.*
.*/adview\..*
.*/AdWorks/.*
.*/adwrapper/.*
.*/AdWrapperIframe\..*
.*/adxx\.php\?.*
.*/adx/fbnvideo/.*
.*/adx/fncvideo/.*
.*/affads/.*
.*/affiliate_.*
.*/affiliate.*/ad/.*
.*/AffiliateBanners/.*
.*/affiliates\.babylon\..*
.*/AffiliateWiz/.*
.*/afr\.php\?.*
.*/ah\.pricegrabber\.com/cb_table\.php.*
.*/aj\.600z\..*
.*/ajrotator/.*
.*/ajs\.php\?.*
.*/anchor\.captainad\..*
.*/annonser/.*
.*/api\.aggregateknowledge\..*
.*/aserve\.directorym\..*
.*/autoPromo.*
.*/banimpress\..*
.*/banman\.asp\?.*
.*/banman/.*
.*/banman\.isoftmarketing\..*
.*/banmanpro/.*&amp;ad.*
.*/banner.*ClickTag=.*
.*/banner/Ad.*
.*/banner_db\.php\?.*
.*/banner_ads\..*
.*/Banner_Management/.*
.*/banner\.php\?.*http.*
.*/banner_file\.php\?.*
.*/bannermanager/.*
.*/bannermedia/.*
.*/banners\?.*&amp;.*
.*/banners/.*
.*/banners/banners\.jsp\?.*
.*/banners\.adultfriendfinder.*
.*/banners\.empoweredcomms\..*
.*/banners/.*\.gif.*
.*/BannerServer/.*
.*/bannerview\..*\?.*
.*/bannery/.*\?banner=.*
.*/bbccom\.js\?.*
.*/bbc\.com/script/1/config\.js.*
.*/bin-layer\..*
.*/blogad_.*
.*/blogads.*
.*/bmp/banman\.asp\?.*
.*/bnrsrv\..*\?.*
.*/boylesportsreklame\..*\?.*
.*/bs\.yandex\.ru.*
.*/c\.adroll\..*
.*/cas\.clickability\.com/.*
.*/clickserv.*
.*/cm8adam.*
.*/cm8space_call.*
.*/cms/Profile_Display/.*
.*/cnnSLads\.js.*
.*/cnwk\..*widgets\.js.*
.*/commercials/splash.*
.*/content\.4chan\.org/tmp/.*
.*/content\.yieldmanager\..*
.*/ContextAd\..*
.*/csDynamic.*
.*/CTAMlive160x160\..*
.*/ctxtlink/.*
.*/d\.m3\.net/.*
.*/d1\.openx\.org/.*&amp;block=.*
.*/da\.feedsportal\.com/r/.*
.*/data\.resultlinks\..*
.*/de.*\.myspace\..*
.*/delivery\.3rdads\..*
.*/descPopup\.js.*
.*/destacados/.*
.*/direct_ads\..*
.*/directads\..*
.*/dontblockthis/.*
.*/DisplayAds.*
.*/DNSads\.html\?.*
.*/dsg/bnn/.*
.*/DynamicAd\?.*
.*/DynamicCSAd\?.*
.*/DynamicVideoAd\?.*&amp;.*
.*/dynBanner/flash/.*
.*/e\.yieldmanager\.net/script\.js.*
.*/eBayISAPI\.dll\?EKServer&amp;.*
.*/ecustomeropinions\.com/popup/.*
.*/ekmas\.com.*
.*/ERALinks/.*
.*/export_feeds\.php\?.*&amp;banner.*
.*/external/ad\.js.*
.*/eyoob\.com/elayer/.*
.*/fairadsnetwork\..*
.*/flashAds\..*
.*/flashbanner/.*
.*/flipmedia.*
.*/forms\.aweber\..*
.*/freetrafficbar\..*
.*/fuseads/.*
.*/gamecast/ads.*
.*/gamersad\..*
.*/gampad/google_service\.js.*
.*/get\.lingospot\..*
.*/getad\.php.*
.*/getad\.php\?.*
.*/get_ad\.php\?.*
.*/getbanner\.cfm\?.*
.*/google_ads/.*
.*/google-adsense.*
.*/googleAd\.js.*
.*/googleframe\..*
.*/hits\.europuls\..*
.*/hits4pay\..*
.*/hotjobs_module\.js.*
.*/houseads/.*
.*/html\.ng/.*
.*/httpads/.*
.*/iframe_ad\..*
.*/iframe-ads/.*
.*/iframead\..*
.*/iframed_.*sessionid=.*
.*/images/ad/.*
.*/images/bnnrs/.*
.*/images/promo/player.*
.*/img\.shopping\.com/sc/pac/shopwidget_.*
.*/index_files/.*\.htm.*
.*/IndianRailways/.*
.*/intext\.js.*
.*/invideoad\..*
.*/itunesaffiliate.*
.*/job_ticker\..*
.*/js\..*\.yahoo\.net/iframe\.php\?.*
.*/js/interstitial_space\.js.*
.*/js/ysc_csc_.*
.*/js\.ng/site=.*
.*/kermit\.macnn\..*
.*/kestrel\.ospreymedialp\..*
.*/l\.yimg\.com/a/a/1-/flash/promotions/.*/0.*
.*/l\.yimg\.com/a/a/1-/java/promotions/.*\.swf.*
.*/launch/testdrive\.gif.*
.*/layer-ads\..*
.*/layerads_.*
.*/LinkExchange/.*
.*/linkreplacer\.js.*
.*/linkshare/.*
.*/listings\..*/iFrame/Dir.*
.*/logos/adLogo.*
.*/lw/ysc_csc_.*
.*/MarbachAdverts\..*
.*/marketing.*partner.*
.*/mac-ad\?.*
.*/magic-ads/.*
.*/media\.funpic\..*/layer\..*
.*/mediamgr\.ugo\..*
.*/medrx\.sensis\.com\.au/.*
.*/miva_ads\..*
.*/MNetOrfad\.js.*
.*/mod_ad/.*
.*/mtvmusic_ads_reporting\.js.*
.*/nascar/.*/defector\.js.*
.*/nascar/.*/promos/.*
.*/network\.sportsyndicator\..*
.*/network\.triadmedianetwork\..*
.*/oas_logic\..*
.*/oasc03\..*
.*/oasisi\.php\?.*
.*/oasisi-.*\.php\?.*
.*/obeus\.com/initframe/.*
.*/openads/.*\?.*
.*/openads2/.*
.*/openx/www/.*
.*/outsidebanners/.*
.*/overture/.*
.*/overture_.*
.*/ox\.bit-tech\.net/delivery/.*
.*/pagead/.*&amp;videoad_start_delay=1.*
.*/pagead/ads\?video_url_to_fetch=.*
.*/pagead/imgad\?.*
.*/pageear/.*
.*/pageear\.js.*
.*/pagepeel.*
.*/partner.*rotate.*
.*/partner\.gonamic\.de/Affiliate/.*
.*/partner\.sbaffiliates\..*
.*/partner\.video\.syndication\.msn\.com/.*
.*/partners/.*
.*/partnership/.*affiliate.*
.*/peel\.js.*
.*/peel1\.js.*
.*/peelad/.*
.*/perfads\.js\?.*
.*/performancingads/.*
.*/pfadx/.*\.mtvi/video;.*
.*/pfadx/comedycentral\..*
.*/phpads/.*
.*/phpads2/.*
.*/phpadserver/.*
.*/pilot_ad\..*
.*/play/ad/.*
.*/player/ad\.htm.*
.*\.plsthx\.com/newaff/.*
.*/podimages/.*
.*/popAds\.js.*
.*/popupjs\..*
.*/processing/impressions \.asp\?.*
.*/promoboxes/.*
.*/promos/.*banner\.gif.*
.*/promos\.fling\..*
.*/printads/.*
.*/psclicks\.asp\?.*
.*/public/ad\?.*
.*/public/bannerjs\..*\?.*=.*
.*/public\.zangocash\..*
.*/publisher\.shopzilla\..*
.*/r\.mail\.ru.*
.*/rad\..*\?GetSAd=.*
.*/reclame/ad\..*
.*/RequestAdvertisement\..*
.*/resources\.infolinks\..*
.*/rhs_promo_.*
.*/rok\.com\.com/.*
.*/rotateAds\..*
.*/rotating_banner.*
.*/rotating\.php.*
.*/rotation/.*\.php\?.*
.*/rover\.ebay\..*&amp;campid=.*
.*/rtq\.careerbuilder\..*
.*/s3\.buysellads\..*
.*/s7121\.vsservers\..*
.*/scripts\.snowball\.com/clinkscontent/.*
.*/search\.spotxchange\.com/.*
.*/shared/promos/.*
.*/show\.asp\?.*_sky.*
.*/show_ad\.ashx\?.*
.*/show_ad_.*
.*/show_afs_ads\.js.*
.*/show_deals\.js.*
.*/show_i\.php\?.*
.*/showad\..*
.*/showads\..*
.*/showbanner\.php\?.*
.*/ShowFlashAd\..*
.*/skyad\.php.*
.*/slideInAd\.js.*
.*/small_ad\..*
.*/socialads\.js.*
.*/softsale/.*
.*/Splash/Page_Header/.*
.*/spinbox\.freedom\..*
.*/sponsImages/.*
.*/sponsorad\..*
.*/sponsored.*
.*/sponsored\.gif.*
.*/squaread\..*
.*/static\.zangocash\..*
.*/support\.biemedia\..*
.*/surveyCookie\.js.*
.*/svgn\.com/.*
.*/testingad\..*
.*/textad\?.*
.*/textAd\..*
.*/tii_ads\.js.*
.*/tikilink\?.*
.*/tizes/a\.aspx\?.*
.*/tmz-adblock/.*
.*/trusearch\.net/affblock/.*
.*/ttz_ad\.js.*
.*/unicast\.ign\.com/assets/.*
.*/upsellitJS2\.jsp\?.*
.*/userbanners/.*
.*/valueclick\..*
.*/vendshow/.*
.*/video\.ap\.org/.*/ad_js\..*
.*/video-cdn\..*_ad_.*
.*/video-cdn\..*_promo_.*
.*/videoad\..*
.*/videoads\..*
.*/videoads/.*
.*/vindicoasset\..*/INSTREAMAD/.*
.*/visit\.homepagle\..*
.*/w1\.buysub\..*
.*/web\.lightningcast\.net/servlets/getPlaylist\?.*
.*/webadImg/.*
.*/webads_.*
.*/whiteglove\.jsp\?.*
.*/widget\.blogrush\.com/show\.js.*
.*/ws\.amazon\..*/widgets/q\?.*
.*/www/delivery/.*
.*/ygames_e/embed/src/embedPlayer\.js.*
.*/ysmads\.html.*
.*//wrapper\.3dgamers\..*
http://171\.66\.124\.80/.*
http://196\.41\.0\.207/.*
http://72\.32\.71\.244.*
http://a\.ads\..*
http://ad.*\.emidiate\..*
http://abm\.hothardware\..*
http://ad-uk\..*
http://ad\..*
http://ad0\..*
http://ad1\..*
http://ad2\..*
http://adbureau\..*
http://adclient.*
http://adcreative\..*
http://adfarm\..*
http://adimg\..*
http://adimages\..*
http://adinterax\..*
http://adnet\..*
http://adonline\..*
http://adq\..*
http://adremote\..*
http://ads\..*
http://ads1\..*
http://ads2\..*
http://ads3\..*
http://ads4\..*
http://ads5\..*
http://adsatt\..*
http://adsearch\..*
http://adserv.*
http://adsnew\..*
http://adsremote\..*
http://adstream\..*\.cgi.*
http://adsvr\..*
http://adsys\..*
http://adt\..*
http://adtags\..*
http://adtech\..*
http://adtology.*
http://adv\..*
http://advert\..*
http://adverts\..*
http://advision\..*/getad.*
http://adworks\..*
http://adx\..*
http://affiliates\..*\.aspx\?.*
http://afimages\..*
http://almobty\.com/.*
http://altfarm\..*
http://avpa\..*
http://banner\..*
http://banners.*&amp;Random=.*
http://banners\..*http.*
http://biz28\..*
http://body\.imho\.ru/.*
http://bwp\..*
http://cbanners\..*
http://cdn\.nvero\..*
http://circads\..*
http://common\..*/slider\.js.*
http://dclk\..*\.ng/.*
http://feeds\..*/~a/.*
http://fdads\.sv\..*
http://ffxcam\..*
http://getad\..*
http://images\..*/banners/.*
http://jazad\..*
http://lads\..*-gutter-.*
http://mads\..*
http://marketing\..*http.*
http://ng3\.ads\..*
http://oas-central\..*
http://pagead2\..*
http://promo2\..*
http://rcm.*\.amazon\..*
http://reklama\..*
http://richmedia2\..*
http://rss\..*/~a/.*
http://servedbyadbutler\..*
http://smartad\..*
http://stocker\.bonnint\..*
http://synad.*
http://ttsrc\.aroq\..*
http://video\.flashtalking\..*
http://wrapper\..*/a\?.*
http://xban\..*/banners/.*
http://.*/partners\..*</property>
            <property name="executeJavaScript" idref="9"/>
            <property name="ancestorProvider" class="BrowserConfigurationSpecificationAncestorProviderForStep"/>
            <property name="changedProperties" class="java.util.HashSet">
              <element class="String">blockedUrlPatterns</element>
              <element class="String">executeJavaScript</element>
              <element class="String">followMetaRedirects</element>
              <element class="String">includedUrlPatterns</element>
              <element class="String">loadFrames</element>
              <element class="String">outputPageIfTimeoutEnabled</element>
            </property>
          </property>
        </property>
        <property name="elementFinders" class="ElementFinders"/>
        <property name="errorHandler" class="ErrorHandler" serializationversion="0">
          <property name="reportingViaAPI" idref="9"/>
          <property name="reportingViaLog" idref="9"/>
          <property name="controlFlow" class="kapow.robot.robomaker.robot.ControlFlow$NextAlternative"/>
        </property>
        <property name="comment">
          <null/>
        </property>
        <property name="enabled" idref="1"/>
        <property name="changedProperties" class="java.util.HashSet">
          <element class="String">name</element>
        </property>
      </object>
      <object class="BranchPoint" id="41"/>
      <object class="Transition" serializationversion="3" id="42">
        <property name="name" class="String">Need more links?</property>
        <property name="stepAction" class="QueryDatabase2" serializationversion="1">
          <property name="sql" class="String">"SELECT count(*)/"+MaxPages+"&gt;5 as Enough FROM wikiPage
where processed='n' and filename is null
and language='"+wikiPage.Language+"'"</property>
          <property name="columnAttributeMappings" class="kapow.robot.plugin.common.support.database.ColumnAttributeMappings">
            <object class="kapow.robot.plugin.common.support.database.ColumnAttributeMapping">
              <property name="columnName" class="String">enough</property>
              <property name="attributeName" class="kapow.robot.plugin.common.support.AttributeName2">
                <property name="name" idref="8"/>
              </property>
            </object>
          </property>
        </property>
        <property name="elementFinders" class="ElementFinders"/>
        <property name="errorHandler" class="ErrorHandler" serializationversion="0"/>
        <property name="comment">
          <null/>
        </property>
        <property name="enabled" idref="1"/>
        <property name="changedProperties" class="java.util.HashSet">
          <element class="String">name</element>
        </property>
      </object>
      <object class="Try" id="43"/>
      <object class="Transition" serializationversion="3" id="44">
        <property name="name" class="String">not enough links?</property>
        <property name="stepAction" class="TestValue" serializationversion="0">
          <property name="condition" class="Expression" serializationversion="1">
            <property name="text" class="String">!temp</property>
          </property>
        </property>
        <property name="elementFinders" class="ElementFinders"/>
        <property name="errorHandler" class="ErrorHandler" serializationversion="0">
          <property name="reportingViaAPI" idref="9"/>
          <property name="reportingViaLog" idref="9"/>
          <property name="controlFlow" class="kapow.robot.robomaker.robot.ControlFlow$BreakLoop"/>
        </property>
        <property name="comment" class="String">don't collect too many pages we don't need.
this robot will find thousands of articles - we don't need so many.</property>
        <property name="enabled" idref="1"/>
        <property name="changedProperties" class="java.util.HashSet">
          <element class="String">name</element>
        </property>
      </object>
      <object class="Transition" serializationversion="3" id="45">
        <property name="name" class="String">For Each Tag Path</property>
        <property name="stepAction" class="ForEachTagPath" serializationversion="0">
          <property name="nodePath" class="String">a</property>
        </property>
        <property name="elementFinders" class="ElementFinders">
          <object class="DefaultNamedElementAwareDOMElementFinder" serializationversion="4">
            <property name="nodePath" class="kapow.robot.plugin.common.support.expression.stringexpr.ValueStringExpression">
              <property name="value" class="String">.*</property>
            </property>
          </object>
        </property>
        <property name="errorHandler" class="ErrorHandler" serializationversion="0"/>
        <property name="comment">
          <null/>
        </property>
        <property name="enabled" idref="1"/>
        <property name="changedProperties" class="java.util.HashSet"/>
      </object>
      <object class="Try" id="46"/>
      <object class="Transition" serializationversion="3" id="47">
        <property name="name" class="String">Link to another Wiki Page?</property>
        <property name="stepAction" class="TestTag" serializationversion="1">
          <property name="pattern" class="kapow.robot.plugin.common.support.expression.stringexpr.PatternValueStringExpression">
            <property name="value" class="String">.*href="/wiki/.*title=.*</property>
          </property>
          <property name="include" idref="1"/>
        </property>
        <property name="elementFinders" class="ElementFinders">
          <object class="DefaultNamedElementAwareDOMElementFinder" serializationversion="4">
            <property name="tagRelation" class="InTagRelation" serializationversion="1">
              <property name="tagName" class="ElementName">
                <property name="name" class="String">1</property>
              </property>
            </property>
            <property name="nodePath" class="kapow.robot.plugin.common.support.expression.stringexpr.ValueStringExpression">
              <property name="value" class="String" id="48">*</property>
            </property>
          </object>
        </property>
        <property name="errorHandler" class="ErrorHandler" serializationversion="0">
          <property name="reportingViaAPI" idref="9"/>
          <property name="reportingViaLog" idref="9"/>
          <property name="controlFlow" class="kapow.robot.robomaker.robot.ControlFlow$NextAlternative"/>
        </property>
        <property name="comment">
          <null/>
        </property>
        <property name="enabled" idref="1"/>
        <property name="changedProperties" class="java.util.HashSet">
          <element idref="18"/>
        </property>
      </object>
      <object class="Transition" serializationversion="3" id="49">
        <property name="name" class="String">Extract URL</property>
        <property name="stepAction" class="ExtractURL">
          <property name="extractionMode" class="kapow.robot.plugin.common.stateprocessor.urlextractor3.TagAttributeURLExtractionMode"/>
          <property name="attributeName" class="kapow.robot.plugin.common.support.AttributeName2">
            <property name="name" class="String">wikiPage.Address</property>
          </property>
          <property name="browserConfigurationSpecification" class="BrowserConfigurationSpecificationWebKit" serializationversion="27">
            <property name="SSLUsage" idref="40"/>
            <property name="ancestorProvider" class="BrowserConfigurationSpecificationAncestorProviderForStep"/>
          </property>
        </property>
        <property name="elementFinders" class="ElementFinders">
          <object class="DefaultNamedElementAwareDOMElementFinder" serializationversion="4">
            <property name="tagRelation" class="InTagRelation" serializationversion="1">
              <property name="tagName" class="ElementName">
                <property name="name" class="String">1</property>
              </property>
            </property>
            <property name="nodePath" class="kapow.robot.plugin.common.support.expression.stringexpr.ValueStringExpression">
              <property name="value" class="String">*</property>
            </property>
          </object>
        </property>
        <property name="errorHandler" class="ErrorHandler" serializationversion="0"/>
        <property name="comment">
          <null/>
        </property>
        <property name="enabled" idref="1"/>
        <property name="changedProperties" class="java.util.HashSet"/>
      </object>
      <object class="Try" id="50"/>
      <object class="Transition" serializationversion="3" id="51">
        <property name="name" class="String">not a real wiki page?</property>
        <property name="stepAction" class="TestValue" serializationversion="0">
          <property name="condition" class="kapow.robot.plugin.common.support.expression.multipletype.StringProcessorsExpression" serializationversion="0">
            <property name="dataConverters" class="DataConverters">
              <element class="GetVariable" serializationversion="2">
                <property name="variable" class="kapow.robot.plugin.common.support.AttributeName2">
                  <property name="name" class="String">wikiPage.Address</property>
                </property>
              </element>
              <element class="Extract2DataConverter">
                <property name="pattern" class="kapow.robot.plugin.common.support.expression.stringexpr.PatternValueStringExpression">
                  <property name="value" class="String">.*(wiki/.*:).*</property>
                </property>
              </element>
            </property>
          </property>
        </property>
        <property name="elementFinders" idref="17"/>
        <property name="errorHandler" class="ErrorHandler" serializationversion="0">
          <property name="reportingViaAPI" idref="9"/>
          <property name="reportingViaLog" idref="9"/>
          <property name="controlFlow" class="kapow.robot.robomaker.robot.ControlFlow$NextAlternative"/>
        </property>
        <property name="comment" class="String">Pages with a colon : in the URL are not articles.</property>
        <property name="enabled" idref="1"/>
        <property name="changedProperties" class="java.util.HashSet">
          <element idref="18"/>
        </property>
      </object>
      <object class="End" id="52"/>
      <object class="Transition" serializationversion="3" id="53">
        <property name="name" class="String">Get language of Page</property>
        <property name="stepAction" class="AssignVariable" serializationversion="4">
          <property name="stringExpr" class="kapow.robot.plugin.common.support.expression.multipletype.StringProcessorsExpression" serializationversion="0">
            <property name="dataConverters" class="DataConverters">
              <element class="GetVariable" serializationversion="2">
                <property name="variable" class="kapow.robot.plugin.common.support.AttributeName2">
                  <property name="name" class="String">wikiPage.Address</property>
                </property>
              </element>
              <element class="Extract2DataConverter">
                <property name="pattern" class="kapow.robot.plugin.common.support.expression.stringexpr.PatternValueStringExpression">
                  <property name="value" class="String">.*//(.*?)\..*</property>
                </property>
              </element>
            </property>
          </property>
          <property name="variable" class="kapow.robot.plugin.common.support.AttributeName2">
            <property name="name" class="String">wikiPage.Language</property>
          </property>
        </property>
        <property name="elementFinders" class="ElementFinders"/>
        <property name="errorHandler" class="ErrorHandler" serializationversion="0">
          <property name="changedProperties" class="java.util.HashSet">
            <element class="String">reportingViaAPI</element>
            <element class="String">reportingViaLog</element>
          </property>
        </property>
        <property name="comment">
          <null/>
        </property>
        <property name="enabled" idref="1"/>
        <property name="changedProperties" class="java.util.HashSet">
          <element class="String">name</element>
        </property>
      </object>
      <object class="Transition" serializationversion="3" id="54">
        <property name="name" class="String">Is this in our language list?</property>
        <property name="stepAction" class="AssignVariable" serializationversion="4">
          <property name="stringExpr" class="kapow.robot.plugin.common.support.expression.multipletype.StringProcessorsExpression" serializationversion="0">
            <property name="dataConverters" class="DataConverters">
              <element class="GetVariable" serializationversion="2">
                <property name="variable" class="kapow.robot.plugin.common.support.AttributeName2">
                  <property name="name" idref="2"/>
                </property>
              </element>
              <element class="Extract2DataConverter">
                <property name="pattern" class="kapow.robot.plugin.common.support.expression2.PatternExpression" serializationversion="1">
                  <property name="text" class="String">".*\\b("+wikiPage.Language+"\\s\\(.*?\\)).*"</property>
                </property>
              </element>
            </property>
          </property>
          <property name="variable" class="kapow.robot.plugin.common.support.AttributeName2">
            <property name="name" class="String">wikiPage.Language</property>
          </property>
        </property>
        <property name="elementFinders" idref="17"/>
        <property name="errorHandler" class="ErrorHandler" serializationversion="0">
          <property name="reportingViaAPI" idref="9"/>
          <property name="reportingViaLog" idref="9"/>
          <property name="controlFlow" class="kapow.robot.robomaker.robot.ControlFlow$NextIteration"/>
        </property>
        <property name="comment">
          <null/>
        </property>
        <property name="enabled" idref="1"/>
        <property name="changedProperties" class="java.util.HashSet">
          <element idref="18"/>
        </property>
      </object>
      <object class="Transition" serializationversion="3" id="55">
        <property name="name" class="String">Extract Title</property>
        <property name="stepAction" class="ExtractTagAttribute2" serializationversion="3">
          <property name="tagAttr" class="String">title</property>
          <property name="Name" class="kapow.robot.plugin.common.support.AttributeName2">
            <property name="name" class="String">wikiPage.Title</property>
          </property>
        </property>
        <property name="elementFinders" class="ElementFinders">
          <object class="DefaultNamedElementAwareDOMElementFinder" serializationversion="4">
            <property name="tagRelation" class="InTagRelation" serializationversion="1">
              <property name="tagName" class="ElementName">
                <property name="name" class="String">1</property>
              </property>
            </property>
            <property name="nodePath" class="kapow.robot.plugin.common.support.expression.stringexpr.ValueStringExpression">
              <property name="value" class="String">*</property>
            </property>
          </object>
        </property>
        <property name="errorHandler" class="ErrorHandler" serializationversion="0">
          <property name="reportingViaAPI" idref="9"/>
          <property name="reportingViaLog" idref="9"/>
          <property name="controlFlow" class="kapow.robot.robomaker.robot.ControlFlow$NextIteration"/>
        </property>
        <property name="comment">
          <null/>
        </property>
        <property name="enabled" idref="1"/>
        <property name="changedProperties" class="java.util.HashSet"/>
      </object>
      <object class="Transition" serializationversion="3" id="56">
        <property name="name" class="String">Link to another Wiki language?</property>
        <property name="stepAction" class="TestTag" serializationversion="1">
          <property name="pattern" class="kapow.robot.plugin.common.support.expression.stringexpr.PatternValueStringExpression">
            <property name="value" class="String">.*href="https://...wikipedia.org/wiki/[^"]+" title=.*</property>
          </property>
          <property name="include" idref="1"/>
        </property>
        <property name="elementFinders" class="ElementFinders">
          <object class="DefaultNamedElementAwareDOMElementFinder" serializationversion="4">
            <property name="tagRelation" class="InTagRelation" serializationversion="1">
              <property name="tagName" class="ElementName">
                <property name="name" class="String">1</property>
              </property>
            </property>
            <property name="nodePath" class="kapow.robot.plugin.common.support.expression.stringexpr.ValueStringExpression">
              <property name="value" class="String">*</property>
            </property>
          </object>
        </property>
        <property name="errorHandler" class="ErrorHandler" serializationversion="0">
          <property name="reportingViaAPI" idref="9"/>
          <property name="reportingViaLog" idref="9"/>
          <property name="controlFlow" class="kapow.robot.robomaker.robot.ControlFlow$NextIteration"/>
        </property>
        <property name="comment">
          <null/>
        </property>
        <property name="enabled" idref="1"/>
        <property name="changedProperties" class="java.util.HashSet">
          <element class="String">name</element>
        </property>
      </object>
      <object class="Transition" serializationversion="3" id="57">
        <property name="name" class="String">processed=true</property>
        <property name="stepAction" class="AssignVariable" serializationversion="4">
          <property name="stringExpr" class="kapow.robot.plugin.common.support.expression.stringexpr.ValueStringExpression">
            <property name="value" class="String">true</property>
          </property>
          <property name="variable" class="kapow.robot.plugin.common.support.AttributeName2">
            <property name="name" class="String">wikiPage.processed</property>
          </property>
        </property>
        <property name="elementFinders" idref="17"/>
        <property name="errorHandler" class="ErrorHandler" serializationversion="0"/>
        <property name="comment">
          <null/>
        </property>
        <property name="enabled" idref="1"/>
        <property name="changedProperties" class="java.util.HashSet">
          <element idref="18"/>
        </property>
      </object>
      <object class="Transition" serializationversion="3" id="58">
        <property name="name" idref="29"/>
        <property name="stepAction" class="StoreInDatabase" serializationversion="0">
          <property name="variableName" class="kapow.robot.plugin.common.support.VariableName">
            <property name="name" class="String">wikiPage</property>
          </property>
          <property name="key" class="kapow.robot.plugin.common.support.expression.multipletype.VariableExpression" serializationversion="2">
            <property name="variable" class="kapow.robot.plugin.common.support.AttributeName2">
              <property name="name" class="String">wikiPage.Address</property>
            </property>
          </property>
        </property>
        <property name="elementFinders" idref="17"/>
        <property name="errorHandler" class="ErrorHandler" serializationversion="0"/>
        <property name="comment">
          <null/>
        </property>
        <property name="enabled" idref="1"/>
        <property name="changedProperties" class="java.util.HashSet"/>
      </object>
      <object class="Transition" serializationversion="3" id="59">
        <property name="name" class="String">Write Log</property>
        <property name="stepAction" class="WriteLog2">
          <property name="expression" class="Expression" serializationversion="1">
            <property name="text" class="String">wikiPage.Language+": " + wikiPage.Title + " : " + wikiPage.Address+ " : " + wikiPage.FileName</property>
          </property>
        </property>
        <property name="elementFinders" class="ElementFinders"/>
        <property name="errorHandler" class="ErrorHandler" serializationversion="0"/>
        <property name="comment">
          <null/>
        </property>
        <property name="enabled" idref="1"/>
        <property name="changedProperties" class="java.util.HashSet"/>
      </object>
      <object class="End" id="60"/>
      <object class="Try" id="61"/>
      <object class="Transition" serializationversion="3" id="62">
        <property name="name" class="String">Set Named Tag</property>
        <property name="stepAction" class="SetNamedTag" serializationversion="0">
          <property name="tagName" class="DesiredElementName">
            <property name="name" class="String">main</property>
          </property>
        </property>
        <property name="elementFinders" class="ElementFinders">
          <object class="DefaultNamedElementAwareDOMElementFinder" serializationversion="4">
            <property name="nodePath" class="kapow.robot.plugin.common.support.expression.stringexpr.ValueStringExpression">
              <property name="value" class="String">.*.div</property>
            </property>
            <property name="attributeName" class="String">id</property>
            <property name="attributeValue" class="kapow.robot.plugin.common.support.predicate.unary.string.FixedStringPredicate">
              <property name="text" class="String">content</property>
            </property>
          </object>
        </property>
        <property name="errorHandler" class="ErrorHandler" serializationversion="0">
          <property name="reportingViaAPI" idref="9"/>
          <property name="reportingViaLog" idref="9"/>
          <property name="controlFlow" class="kapow.robot.robomaker.robot.ControlFlow$NextAlternative"/>
        </property>
        <property name="comment">
          <null/>
        </property>
        <property name="enabled" idref="1"/>
        <property name="changedProperties" class="java.util.HashSet"/>
      </object>
      <object class="BranchPoint" id="63"/>
      <object class="Transition" serializationversion="3" id="64">
        <property name="name" class="String">text=""</property>
        <property name="stepAction" class="AssignVariable" serializationversion="4">
          <property name="variable" class="kapow.robot.plugin.common.support.AttributeName2">
            <property name="name" idref="7"/>
          </property>
        </property>
        <property name="elementFinders" class="ElementFinders"/>
        <property name="errorHandler" class="ErrorHandler" serializationversion="0"/>
        <property name="comment">
          <null/>
        </property>
        <property name="enabled" idref="1"/>
        <property name="changedProperties" class="java.util.HashSet">
          <element class="String">name</element>
        </property>
      </object>
      <object class="Try" id="65"/>
      <object class="Transition" serializationversion="3" id="66">
        <property name="name" class="String">For Each Paragraph</property>
        <property name="stepAction" class="ForEachTagPath" serializationversion="0">
          <property name="nodePath" class="String">p</property>
        </property>
        <property name="elementFinders" class="ElementFinders">
          <object class="DefaultNamedElementAwareDOMElementFinder" serializationversion="4">
            <property name="tagRelation" class="InTagRelation" serializationversion="1">
              <property name="tagName" class="ElementName">
                <property name="name" class="String">main</property>
              </property>
            </property>
            <property name="nodePath" class="kapow.robot.plugin.common.support.expression.stringexpr.ValueStringExpression">
              <property name="value" idref="48"/>
            </property>
          </object>
        </property>
        <property name="errorHandler" class="ErrorHandler" serializationversion="0">
          <property name="reportingViaAPI" idref="9"/>
          <property name="reportingViaLog" idref="9"/>
          <property name="controlFlow" class="kapow.robot.robomaker.robot.ControlFlow$NextAlternative"/>
        </property>
        <property name="comment">
          <null/>
        </property>
        <property name="enabled" idref="1"/>
        <property name="changedProperties" class="java.util.HashSet">
          <element class="String" id="67">name</element>
        </property>
      </object>
      <object class="Transition" serializationversion="3" id="68">
        <property name="name" class="String">Append to Text</property>
        <property name="stepAction" class="Extract" serializationversion="1">
          <property name="dataConverters" class="DataConverters">
            <element class="ReplacePattern">
              <property name="pattern" class="kapow.robot.plugin.common.support.expression.stringexpr.PartialInputMatchingPatternValueStringExpression">
                <property name="value" class="String">(\[\d+\])</property>
              </property>
              <property name="replaceExp" class="String">""</property>
              <property name="specifiedDescription" class="String">Remove Footnotes</property>
            </element>
            <element class="EvaluateExpression" serializationversion="0">
              <property name="expression" class="String">Text+"\n"+INPUT</property>
            </element>
          </property>
          <property name="attributeName" class="kapow.robot.plugin.common.support.AttributeName2">
            <property name="name" idref="7"/>
          </property>
        </property>
        <property name="elementFinders" class="ElementFinders">
          <object class="DefaultNamedElementAwareDOMElementFinder" serializationversion="4">
            <property name="tagRelation" class="InTagRelation" serializationversion="1">
              <property name="tagName" class="ElementName">
                <property name="name" class="String">1</property>
              </property>
            </property>
            <property name="nodePath" class="kapow.robot.plugin.common.support.expression.stringexpr.ValueStringExpression">
              <property name="value" idref="48"/>
            </property>
          </object>
        </property>
        <property name="errorHandler" class="ErrorHandler" serializationversion="0"/>
        <property name="comment">
          <null/>
        </property>
        <property name="enabled" idref="1"/>
        <property name="changedProperties" class="java.util.HashSet">
          <element idref="67"/>
        </property>
      </object>
      <object class="End" id="69"/>
      <object class="Transition" serializationversion="3" id="70">
        <property name="name" class="String">Do Nothing</property>
        <property name="stepAction" class="DoNothing"/>
        <property name="elementFinders" idref="17"/>
        <property name="errorHandler" class="ErrorHandler" serializationversion="0"/>
        <property name="comment" class="String">This page has no text</property>
        <property name="enabled" idref="1"/>
        <property name="changedProperties" class="java.util.HashSet"/>
      </object>
      <object class="Transition" serializationversion="3" id="71">
        <property name="name" class="String">Set Text</property>
        <property name="stepAction" class="AssignVariable" serializationversion="4">
          <property name="stringExpr" class="kapow.robot.plugin.common.support.expression.multipletype.ComplexVariableAllowedVariableExpression" serializationversion="2">
            <property name="variable" class="kapow.robot.plugin.common.support.AttributeName2">
              <property name="name" idref="7"/>
            </property>
          </property>
          <property name="variable" class="kapow.robot.plugin.common.support.AttributeName2">
            <property name="name" class="String">wikiPage.Text</property>
          </property>
        </property>
        <property name="elementFinders" class="ElementFinders"/>
        <property name="errorHandler" class="ErrorHandler" serializationversion="0"/>
        <property name="comment">
          <null/>
        </property>
        <property name="enabled" idref="1"/>
        <property name="changedProperties" class="java.util.HashSet">
          <element class="String">name</element>
        </property>
      </object>
      <object class="Try" id="72"/>
      <object class="Transition" serializationversion="3" id="73">
        <property name="name" class="String">article more than 2000 characters?</property>
        <property name="stepAction" class="TestValue" serializationversion="0">
          <property name="condition" class="Expression" serializationversion="1">
            <property name="text" class="String">length(Text)&gt;2000</property>
          </property>
        </property>
        <property name="elementFinders" idref="17"/>
        <property name="errorHandler" class="ErrorHandler" serializationversion="0">
          <property name="reportingViaAPI" idref="9"/>
          <property name="reportingViaLog" idref="9"/>
          <property name="controlFlow" class="kapow.robot.robomaker.robot.ControlFlow$NextAlternative"/>
        </property>
        <property name="comment">
          <null/>
        </property>
        <property name="enabled" idref="1"/>
        <property name="changedProperties" class="java.util.HashSet">
          <element idref="18"/>
        </property>
      </object>
      <object class="Transition" serializationversion="3" id="74">
        <property name="name" class="String">Assign/Truncate File Name</property>
        <property name="stepAction" class="AssignVariable" serializationversion="4">
          <property name="stringExpr" class="kapow.robot.plugin.common.support.expression.multipletype.StringProcessorsExpression" serializationversion="0">
            <property name="dataConverters" class="DataConverters">
              <element class="GetVariable" serializationversion="2">
                <property name="variable" class="kapow.robot.plugin.common.support.AttributeName2">
                  <property name="name" class="String">wikiPage.Title</property>
                </property>
              </element>
              <element class="EvaluateExpression" serializationversion="0">
                <property name="expression" class="String">length(INPUT)&gt;100?substring(INPUT,0,99):INPUT</property>
                <property name="specifiedDescription" class="String">truncate name to 100 characters</property>
              </element>
              <element class="RemoveSpecialCharacters"/>
              <element class="EvaluateExpression" serializationversion="0">
                <property name="expression" class="String">ProjectPath+"\\"+wikiPage.Language+"\\"+INPUT +".txt"</property>
              </element>
            </property>
          </property>
          <property name="variable" class="kapow.robot.plugin.common.support.AttributeName2">
            <property name="name" class="String">wikiPage.FileName</property>
          </property>
        </property>
        <property name="elementFinders" class="ElementFinders"/>
        <property name="errorHandler" class="ErrorHandler" serializationversion="0"/>
        <property name="comment">
          <null/>
        </property>
        <property name="enabled" idref="1"/>
        <property name="changedProperties" class="java.util.HashSet">
          <element class="String">name</element>
        </property>
      </object>
      <object class="Transition" serializationversion="3" id="75">
        <property name="name" class="String">Write BOM</property>
        <property name="stepAction" class="WriteFile" serializationversion="0">
          <property name="fileNameExpression" class="kapow.robot.plugin.common.support.expression.multipletype.VariableExpression" serializationversion="2">
            <property name="variable" class="kapow.robot.plugin.common.support.AttributeName2">
              <property name="name" class="String">wikiPage.FileName</property>
            </property>
          </property>
          <property name="fileContentExpression" class="kapow.robot.plugin.common.support.expression.multipletype.StringProcessorsExpression" serializationversion="0">
            <property name="dataConverters" class="DataConverters">
              <element class="EvaluateExpression" serializationversion="0">
                <property name="expression" class="String">"\u00EF\u00BB\u00BF"</property>
              </element>
              <element class="ConvertTextToBinary">
                <property name="encoding" class="Encoding">
                  <property name="encoding" class="String">ISO-8859-1</property>
                </property>
              </element>
            </property>
          </property>
          <property name="fileEncoding" class="Encoding">
            <property name="encoding" class="String">US-ASCII</property>
          </property>
          <property name="createDirectories" idref="1"/>
          <property name="executeInRoboMaker" idref="1"/>
        </property>
        <property name="elementFinders" class="ElementFinders"/>
        <property name="errorHandler" class="ErrorHandler" serializationversion="0"/>
        <property name="comment" class="String">The Unicode Byte-Order-Marker
required by Kofax Transformation for correctly interpreting Unicode Text Files</property>
        <property name="enabled" idref="1"/>
        <property name="changedProperties" class="java.util.HashSet">
          <element class="String">name</element>
        </property>
      </object>
      <object class="Transition" serializationversion="3" id="76">
        <property name="name" class="String">Write File</property>
        <property name="stepAction" class="WriteFile" serializationversion="0">
          <property name="fileNameExpression" class="kapow.robot.plugin.common.support.expression.multipletype.VariableExpression" serializationversion="2">
            <property name="variable" class="kapow.robot.plugin.common.support.AttributeName2">
              <property name="name" class="String">wikiPage.FileName</property>
            </property>
          </property>
          <property name="fileContentExpression" class="kapow.robot.plugin.common.support.expression.multipletype.VariableExpression" serializationversion="2">
            <property name="variable" class="kapow.robot.plugin.common.support.AttributeName2">
              <property name="name" class="String">wikiPage.Text</property>
            </property>
          </property>
          <property name="appendToFile" idref="1"/>
          <property name="createDirectories" idref="1"/>
          <property name="executeInRoboMaker" idref="1"/>
        </property>
        <property name="elementFinders" class="ElementFinders"/>
        <property name="errorHandler" class="ErrorHandler" serializationversion="0"/>
        <property name="comment">
          <null/>
        </property>
        <property name="enabled" idref="1"/>
        <property name="changedProperties" class="java.util.HashSet"/>
      </object>
      <object class="Transition" serializationversion="3" id="77">
        <property name="name" class="String">Test Set</property>
        <property name="stepAction" class="AssignVariable" serializationversion="4">
          <property name="stringExpr" class="Expression" serializationversion="1">
            <property name="text" class="String">ProjectPath+"\\samples\\test"</property>
          </property>
          <property name="variable" class="kapow.robot.plugin.common.support.AttributeName2">
            <property name="name" class="String">ProjectPath</property>
          </property>
        </property>
        <property name="elementFinders" class="ElementFinders"/>
        <property name="errorHandler" class="ErrorHandler" serializationversion="0"/>
        <property name="comment">
          <null/>
        </property>
        <property name="enabled" idref="1"/>
        <property name="changedProperties" class="java.util.HashSet">
          <element class="String">name</element>
        </property>
      </object>
      <object class="Transition" serializationversion="3" id="78">
        <property name="name" class="String">Get More Documents!</property>
        <property name="stepAction" class="AssignVariable" serializationversion="4">
          <property name="stringExpr" class="Expression" serializationversion="1">
            <property name="text" class="String">MaxPages*2</property>
          </property>
          <property name="variable" class="kapow.robot.plugin.common.support.AttributeName2">
            <property name="name" idref="4"/>
          </property>
        </property>
        <property name="elementFinders" class="ElementFinders"/>
        <property name="errorHandler" class="ErrorHandler" serializationversion="0"/>
        <property name="comment">
          <null/>
        </property>
        <property name="enabled" idref="1"/>
        <property name="changedProperties" class="java.util.HashSet">
          <element class="String">name</element>
        </property>
      </object>
      <object class="Transition" serializationversion="3" id="79">
        <property name="name" class="String">Assign Address</property>
        <property name="stepAction" class="AssignVariable" serializationversion="4">
          <property name="stringExpr" class="kapow.robot.plugin.common.support.expression.stringexpr.ValueStringExpression">
            <property name="value" class="String">https://ja.wikipedia.org/wiki/%E3%82%A4%E3%82%B9%E3%82%BF%E3%83%B3%E3%83%96%E3%83%BC%E3%83%AB</property>
          </property>
          <property name="variable" class="kapow.robot.plugin.common.support.AttributeName2">
            <property name="name" class="String">wikiPage.Address</property>
          </property>
        </property>
        <property name="elementFinders" idref="25"/>
        <property name="errorHandler" class="ErrorHandler" serializationversion="0"/>
        <property name="comment">
          <null/>
        </property>
        <property name="enabled" idref="1"/>
        <property name="changedProperties" class="java.util.HashSet"/>
      </object>
    </steps>
    <blockEndStep class="BlockEndStep"/>
    <edges class="ArrayList">
      <object class="TransitionEdge">
        <from idref="10"/>
        <to idref="11"/>
        <name/>
        <comment/>
      </object>
      <object class="TransitionEdge">
        <from idref="11"/>
        <to idref="12"/>
        <name/>
        <comment/>
      </object>
      <object class="TransitionEdge">
        <from idref="11"/>
        <to idref="79"/>
        <name/>
        <comment/>
      </object>
      <object class="TransitionEdge">
        <from idref="12"/>
        <to idref="13"/>
        <name/>
        <comment/>
      </object>
      <object class="TransitionEdge">
        <from idref="12"/>
        <to idref="77"/>
        <name/>
        <comment/>
      </object>
      <object class="TransitionEdge">
        <from idref="13"/>
        <to idref="14"/>
        <name/>
        <comment/>
      </object>
      <object class="TransitionEdge">
        <from idref="14"/>
        <to idref="15"/>
        <name/>
        <comment/>
      </object>
      <object class="TransitionEdge">
        <from idref="14"/>
        <to idref="31"/>
        <name/>
        <comment/>
      </object>
      <object class="TransitionEdge">
        <from idref="15"/>
        <to idref="16"/>
        <name/>
        <comment/>
      </object>
      <object class="TransitionEdge">
        <from idref="16"/>
        <to idref="19"/>
        <name/>
        <comment/>
      </object>
      <object class="TransitionEdge">
        <from idref="19"/>
        <to idref="20"/>
        <name/>
        <comment/>
      </object>
      <object class="TransitionEdge">
        <from idref="20"/>
        <to idref="21"/>
        <name/>
        <comment/>
      </object>
      <object class="TransitionEdge">
        <from idref="21"/>
        <to idref="22"/>
        <name/>
        <comment/>
      </object>
      <object class="TransitionEdge">
        <from idref="21"/>
        <to idref="24"/>
        <name/>
        <comment/>
      </object>
      <object class="TransitionEdge">
        <from idref="22"/>
        <to idref="23"/>
        <name/>
        <comment/>
      </object>
      <object class="TransitionEdge">
        <from idref="24"/>
        <to idref="26"/>
        <name/>
        <comment/>
      </object>
      <object class="TransitionEdge">
        <from idref="26"/>
        <to idref="27"/>
        <name/>
        <comment/>
      </object>
      <object class="TransitionEdge">
        <from idref="27"/>
        <to idref="28"/>
        <name/>
        <comment/>
      </object>
      <object class="TransitionEdge">
        <from idref="28"/>
        <to idref="30"/>
        <name/>
        <comment/>
      </object>
      <object class="TransitionEdge">
        <from idref="31"/>
        <to idref="32"/>
        <name/>
        <comment/>
      </object>
      <object class="TransitionEdge">
        <from idref="32"/>
        <to idref="33"/>
        <name/>
        <comment/>
      </object>
      <object class="TransitionEdge">
        <from idref="33"/>
        <to idref="34"/>
        <name/>
        <comment/>
      </object>
      <object class="TransitionEdge">
        <from idref="34"/>
        <to idref="35"/>
        <name/>
        <comment/>
      </object>
      <object class="TransitionEdge">
        <from idref="35"/>
        <to idref="36"/>
        <name/>
        <comment/>
      </object>
      <object class="TransitionEdge">
        <from idref="35"/>
        <to idref="57"/>
        <name/>
        <comment/>
      </object>
      <object class="TransitionEdge">
        <from idref="36"/>
        <to idref="37"/>
        <name/>
        <comment/>
      </object>
      <object class="TransitionEdge">
        <from idref="37"/>
        <to idref="38"/>
        <name/>
        <comment/>
      </object>
      <object class="TransitionEdge">
        <from idref="38"/>
        <to idref="39"/>
        <name/>
        <comment/>
      </object>
      <object class="TransitionEdge">
        <from idref="38"/>
        <to idref="57"/>
        <name/>
        <comment/>
      </object>
      <object class="TransitionEdge">
        <from idref="39"/>
        <to idref="41"/>
        <name/>
        <comment/>
      </object>
      <object class="TransitionEdge">
        <from idref="41"/>
        <to idref="42"/>
        <name/>
        <comment/>
      </object>
      <object class="TransitionEdge">
        <from idref="41"/>
        <to idref="61"/>
        <name/>
        <comment/>
      </object>
      <object class="TransitionEdge">
        <from idref="42"/>
        <to idref="43"/>
        <name/>
        <comment/>
      </object>
      <object class="TransitionEdge">
        <from idref="43"/>
        <to idref="44"/>
        <name/>
        <comment/>
      </object>
      <object class="TransitionEdge">
        <from idref="43"/>
        <to idref="57"/>
        <name/>
        <comment/>
      </object>
      <object class="TransitionEdge">
        <from idref="44"/>
        <to idref="45"/>
        <name/>
        <comment/>
      </object>
      <object class="TransitionEdge">
        <from idref="45"/>
        <to idref="46"/>
        <name/>
        <comment/>
      </object>
      <object class="TransitionEdge">
        <from idref="46"/>
        <to idref="47"/>
        <name/>
        <comment/>
      </object>
      <object class="TransitionEdge">
        <from idref="46"/>
        <to idref="56"/>
        <name/>
        <comment/>
      </object>
      <object class="TransitionEdge">
        <from idref="47"/>
        <to idref="49"/>
        <name/>
        <comment/>
      </object>
      <object class="TransitionEdge">
        <from idref="49"/>
        <to idref="50"/>
        <name/>
        <comment/>
      </object>
      <object class="TransitionEdge">
        <from idref="50"/>
        <to idref="51"/>
        <name/>
        <comment/>
      </object>
      <object class="TransitionEdge">
        <from idref="50"/>
        <to idref="53"/>
        <name/>
        <comment/>
      </object>
      <object class="TransitionEdge">
        <from idref="51"/>
        <to idref="52"/>
        <name/>
        <comment/>
      </object>
      <object class="TransitionEdge">
        <from idref="53"/>
        <to idref="54"/>
        <name/>
        <comment/>
      </object>
      <object class="TransitionEdge">
        <from idref="54"/>
        <to idref="55"/>
        <name/>
        <comment/>
      </object>
      <object class="TransitionEdge">
        <from idref="55"/>
        <to idref="21"/>
        <name/>
        <comment/>
      </object>
      <object class="TransitionEdge">
        <from idref="56"/>
        <to idref="49"/>
        <name/>
        <comment/>
      </object>
      <object class="TransitionEdge">
        <from idref="57"/>
        <to idref="58"/>
        <name/>
        <comment/>
      </object>
      <object class="TransitionEdge">
        <from idref="58"/>
        <to idref="59"/>
        <name/>
        <comment/>
      </object>
      <object class="TransitionEdge">
        <from idref="59"/>
        <to idref="60"/>
        <name/>
        <comment/>
      </object>
      <object class="TransitionEdge">
        <from idref="61"/>
        <to idref="62"/>
        <name/>
        <comment/>
      </object>
      <object class="TransitionEdge">
        <from idref="61"/>
        <to idref="57"/>
        <name/>
        <comment/>
      </object>
      <object class="TransitionEdge">
        <from idref="62"/>
        <to idref="63"/>
        <name/>
        <comment/>
      </object>
      <object class="TransitionEdge">
        <from idref="63"/>
        <to idref="64"/>
        <name/>
        <comment/>
      </object>
      <object class="TransitionEdge">
        <from idref="63"/>
        <to idref="71"/>
        <name/>
        <comment/>
      </object>
      <object class="TransitionEdge">
        <from idref="64"/>
        <to idref="65"/>
        <name/>
        <comment/>
      </object>
      <object class="TransitionEdge">
        <from idref="65"/>
        <to idref="66"/>
        <name/>
        <comment/>
      </object>
      <object class="TransitionEdge">
        <from idref="65"/>
        <to idref="70"/>
        <name/>
        <comment/>
      </object>
      <object class="TransitionEdge">
        <from idref="66"/>
        <to idref="68"/>
        <name/>
        <comment/>
      </object>
      <object class="TransitionEdge">
        <from idref="68"/>
        <to idref="69"/>
        <name/>
        <comment/>
      </object>
      <object class="TransitionEdge">
        <from idref="70"/>
        <to idref="57"/>
        <name/>
        <comment/>
      </object>
      <object class="TransitionEdge">
        <from idref="71"/>
        <to idref="72"/>
        <name/>
        <comment/>
      </object>
      <object class="TransitionEdge">
        <from idref="72"/>
        <to idref="73"/>
        <name/>
        <comment/>
      </object>
      <object class="TransitionEdge">
        <from idref="72"/>
        <to idref="57"/>
        <name/>
        <comment/>
      </object>
      <object class="TransitionEdge">
        <from idref="73"/>
        <to idref="74"/>
        <name/>
        <comment/>
      </object>
      <object class="TransitionEdge">
        <from idref="74"/>
        <to idref="75"/>
        <name/>
        <comment/>
      </object>
      <object class="TransitionEdge">
        <from idref="75"/>
        <to idref="76"/>
        <name/>
        <comment/>
      </object>
      <object class="TransitionEdge">
        <from idref="76"/>
        <to idref="57"/>
        <name/>
        <comment/>
      </object>
      <object class="TransitionEdge">
        <from idref="77"/>
        <to idref="78"/>
        <name/>
        <comment/>
      </object>
      <object class="TransitionEdge">
        <from idref="78"/>
        <to idref="14"/>
        <name/>
        <comment/>
      </object>
      <object class="TransitionEdge">
        <from idref="79"/>
        <to idref="38"/>
        <name/>
        <comment/>
      </object>
    </edges>
  </property>
  <property name="browserConfigurationSpecification" class="BrowserConfigurationSpecificationWebKit" serializationversion="27">
    <property name="SSLUsage" idref="40"/>
    <property name="blockedUrlPatterns" class="String">.*-adspace.*
.*&amp;adspace=.*
.*=viewAdJs.*
.*&amp;affiliate=.*
.*&amp;ClientType=.*&amp;AdID=.*
.*&amp;google_adpage=.*
.*\?adtype=.*
.*\?affiliate.*
.*\?getad=&amp;.*
.*\?resizediv=.*promo=.*
.*\?showbanner=.*
.*_ad\.aspx.*
.*_adbrite.*
.*_adfunction.*
.*_ads/.*
.*_ads\.php\?.*
.*_adspace.*
.*_advertisement.*\.gif.*
.*_banner_ad.*
.*_bannerid.*random.*
.*_companionad\..*
.*_skyscraper_.*
.*_videoad\..*
.*adaffiliate.*
.*AdIFrame.*
.*admentor.*
.*ADTECH;cookie=.*
.*ads\.sv\.publicus\..*
.*adsfac\.net.*
.*adwords\.google\..*imgad.*
.*affiliatebrand\..*
.*audienceprofiler\..*
.*aurora-.*marketing\.co.*
.*banner-ad.*
.*bannerad.*
.*BannerMangement.*
.*banners&amp;id=.*
.*blog\.tmcnet\..*/overlib\.js.*
.*brandcentral\..*
.*Click.*Advertiser.*
.*clicktag=.*/ad.*
.*content\.search.*
.*adserving\.cpxinteractive.*
.*cubics\.com/.*
.*dbbsrv\.com.*
.*dgmaustralia\..*
.*download-door\.search\.com/search.*
.*dynamicad\..*
.*earthlink.*/promos.*
.*eas\.blocket\..*
.*engine\.awaps\.net/.*
.*exitexplosion\..*/exit\.js.*
.*expedia_ad\..*
.*faireagle\.com.*
.*favinfo\.com/ad\..*
.*gamesbanner\.net/.*
.*geocities\.com/js_source/.*
.*google\.com.*/promo_.*
.*hera\.hardocp\..*
.*imageshack.*tagworld.*
.*interclick\..*
.*js\.worthathousandwords\..*
.*js2\.yimg\..*_popup_.*
.*kanoodle.*
.*leftsidead\..*
.*link_ads.*
.*maps\.google\.com.*.*mediacorpsingapore.*
.*medrx\.sensis\.com\.au/content/.*
.*nebuad\.com.*
.*netspiderads.*
.*network\.ninemsn\..*/share/.*
.*nbjmp\.com/.*
.*openbanner.*
.*page\.grabclick\..*
.*phpadsnew.*
.*popinads\..*
.*popunder.*
.*popup_ad\..*
.*precisionclick\..*
.*pro-market\..*
.*promopop.*
.*ptnrcontent.*
.*publicidad.*
.*quigo\.com.*
.*rad\.live\.com/ADSAdClient.*
.*richmedia\..*yimg\..*
.*rightsidead\..*
.*s\.trigami\..*
.*space\.com/.*interstitial_space\.js.*
.*sponslink.*
.*sponsor\.gif.*
.*sponsorads.*
.*sponsored_links.*
.*sponsors.*banner.*
.*sys-con\.com/common/.*
.*targetpoint\.com.*
.*textlink-ads\..*
.*themis\.yahoo\..*
.*vs20060817\.com/.*
.*worsethanfailure\..*/Tizes/.*
.*www\.cb\.cl/.*banner.*
.*www\.ad\.tomshardware\..*=banner.*
.*xcelsiusadserver\..*
.*yceml\.net.*
.*\.1100i\.com/.*
.*\.188server\..*
.*\.2mdn\.net/.*
.*\.360ads\..*
.*\.43plc\.com.*
.*\.about\.com/0/.*
.*\.accuserveadsystem\..*
.*\.acronym\.com/.*
.*\.ad\.tomshardware\.com/.*
.*\.ad\.twitchguru\..*
.*\.ad-flow\..*
.*\.ad20\.net/.*
.*\.ad4cash\..*
.*\.adaction\..*
.*\.adbard\.net/ab.*
.*\.adblade\.com/.*
.*\.adbrite\.com/mb/.*
.*\.adbureau\..*
.*\.adbutler\..*
.*\.adcentriconline\..*
.*\.adchap\..*
.*\.adecn\.com/.*
.*\.adengage\..*
.*\.adf01\.net/.*
.*\.adfusion\..*
.*\.adgardener\..*
.*\.adgine\..*
.*\.adgroups\..*
.*\.adhese\..*
.*\.adicate\..*
.*\.adition\.com/.*
.*\.adinterax\..*
.*\.adireland\..*
.*\.adjuggler\..*
.*\.admarketplace\..*
.*\.adnet\.biz.*
.*\.adlink\.net.*
.*\.adnet\.ru.*
.*\.adocean\..*
.*\.adoperator\..*
.*\.adotube\.com/overstreamPlatform/.*
.*\.adpark\..*
.*\.adpinion\..*
.*\.adsdk\.com/.*
.*\.adserver\..*\?.*
.*\.adservinginternational\..*
.*\.adsforindians\..*
.*\.adshopping\..*
.*\.adshuffle\..*
.*\.adsmarket\..*
.*\.adsonar\..*
.*\.adspeed\..*
.*\.adtext\..*
.*\.adtmedia\..*
.*\.adtology3\..*
.*\.adtoma\.com/.*
.*\.adtrgt\..*
.*\.adultadworld\..*
.*\.adultfriendfinder\.com/banners/.*
.*\.adverserve\..*
.*\.advertarium\..*
.*\.adverticum\.net/.*
.*\.advertising\..*
.*\.advertising-department\.com.*\.php\?.*
.*\.advertlets\..*
.*\.advertserve\..*
.*\.adviva\..*
.*\.adxpower\..*
.*\.agentcenters\..*
.*\.afcyhf\..*
.*\.affiliate\..*
.*\.affiliatefuel\..*
.*\.affiliatefuture\..*
.*\.affiliproducts\.com/showProducts\..*
.*\.affiliatesensor\..*
.*\.affilimatch\..*
.*\.aim4media\..*
.*\.akamai\..*sponsor.*
.*\.alphagodaddy\..*
.*\.anrdoezrs\..*
.*\.arcadebanners\..*
.*\.as5000\..*
.*\.ase\.cc/.*
.*\.assoc-amazon\..*
.*\.atdmt\.com/.*
.*\.atwola\..*
.*\.auspipe\..*
.*\.avads\.co\.uk/.*
.*\.awin1\.com.*
.*\.awltovhc\..*
.*\.axill\.com/.*
.*\.azads\.com/.*
.*\.azjmp\.com/.*
.*\.azoogleads\..*
.*\.bannerbank\.ru/.*
.*\.bannerconnect\..*
.*\.bannersmania\..*
.*\.bbc\.co\.uk/.*/vs\.js.*
.*\.begun\.ru/.*
.*\.belointeractive\..*
.*\.bestofferdirect\..*
.*\.bidvertiser\..*
.*\.bimedia\.net/video/.*
.*\.blogads\.com/.*
.*\.bloggerads\..*
.*\.bluestreak\..*
.*\.bravenetmedianetwork\..*
.*\.bravenet\..*/rover/.*
.*\.bridgetrack\..*
.*\.btrll\.com/.*
.*\.burstnet\..*
.*\.c-on-text\..*
.*\.c8\.net\.ua/.*
.*\.casalemedia\..*
.*\.cc-dt\.com/.*
.*\.centralmediaserver\..*
.*\.cgecwm\.org/.*
.*\.checkm8\..*
.*\.checkmystats\..*
.*\.chitika\..*
.*\.ciao\.co\.uk/load_file\.php\?.*
.*\.cjt1\.net.*
.*\.clash-media\..*
.*\.claxonmedia\..*
.*\.clickad\..*
.*\.clickbooth.*
.*\.clickexperts\..*
.*\.clickintext\..*
.*\.clickthrucash\..*
.*\.clixgalore\..*
.*\.co\.uk/ads\.pl.*
.*\.codeproject\..*/ServeImg\..*
.*\.cogsdigital\..*
.*\.com/ads\.pl.*
.*\.com/sideads.*
.*\.com/topads.*
.*\.commission-junction\..*
.*\.commissionmonster\..*
.*\.connextra\..*
.*\.contextuads\..*
.*\.contextweb\..*
.*\.cpaclicks.*
.*\.cpays\.com/.*
.*\.cpmstar\..*
.*\.cpuim\.com/.*
.*\.crashextads\..*
.*\.crispads\..*
.*\.decisionmark\..*
.*\.decisionnews\..*
.*\.deepmetrix\..*
.*\.dl-rms\.com/.*
.*\.domainsponsor\..*
.*\.doubleclick\.net/adi/.*
.*\.doubleclick\.net/adj/.*
.*\.doubleclick\.net/pfadx/.*
.*\.doubleclick\.net/.*;cue=pre;.*
.*\.dpbolvw\..*
.*\.dynw\.com/banner.*
.*\.ebayrtm\.com/rtm\?rtmcmd&amp;a=json.*
.*\.ebaystatic\./adserver.*
.*\.edge\.ru4\..*
.*\.egotastic\.com/obp-.*
.*\.emediate\..*
.*\.etology\..*
.*\.euroclick\..*
.*\.exponential\..*
.*\.eyereturn\..*
.*\.eyewonder\..*
.*\.falkag\..*
.*\.fastclick\..*
.*\.feedburner\.com/~a/.*
.*\.filefront\..*/fnOverlay\.js.*
.*\.fimserve\..*
.*\.firstadsolution\..*
.*\.firstlightera\.com/era/.*
.*\.fixionmedia\..*
.*\.fmpub\.net/.*
.*\.forrestersurveys\..*
.*\.fluxads\..*
.*\.flyordie\.com/games/free/b/.*--\?p=.*
.*\.friendlyduck\..*
.*\.ftjcfx\..*
.*\.funklicks\..*
.*\.fwmrm\.net/.*\.flv.*
.*\.fwmrm\.net/.*\.swf.*
.*\.g\.akamai\..*/ads\..*
.*\.game-advertising-online\..*
.*\.gamecetera\..*
.*\.gamersbanner\..*
.*\.geopromos\..*
.*\.gestionpub\..*
.*\.getprice\.com\.au/searchwidget\.aspx\?.*
.*\.gklmedia\..*
.*\.go\.com/.*ads\.js.*
.*\.go\.globaladsales\.com/.*
.*/googleads\.g\.doubleclick\.net/pagead/.*
.*\.googleadservices\..*
.*\.grabmyads\..*
.*\.gumgum\..*/ggv2\.js.*
.*\.henwo\.com/.*
.*\.hit-now\..*
.*\.hosticanaffiliate\..*
.*\.httpool\..*
.*\.hypemakers\..*
.*\.hypervre\..*
.*\.ibatom\..*/syndication/.*
.*\.ic-live\..*
.*\.icdirect\..*
.*\.idg\.com\.au/images/.*_promo.*
.*\.imagesatlantic\..*
.*\.imedia\.co\.il/.*
.*\.infinite-ads\..*
.*\.imglt\.com/.*
.*\.impresionesweb\..*
.*\.indiads\..*
.*\.industrybrains\..*
.*\.inetinteractive\..*
.*\.infocious\..*
.*\.intellitxt\..*
.*\.interpolls\..*
.*\.jdoqocy\..*
.*\.jumboaffiliates\..*
.*\.jydesign\..*
.*\.ketoo\.com/.*
.*\.klipmart\..*
.*\.kontera\..*
.*\.kqzyfj\..*
.*\.leadacceptor\..*
.*\.lduhtrp\..*
.*\.lightningcast\..*
.*\.linkads\..*\?.*
.*\.linkexchange\..*
.*\.linkworth\..*
.*\.litres\.ru/static/banner/.*
.*\.ltassrv\..*
.*\.main\.ebayrtm\.com/rtm\?RtmCmd&amp;a=inline&amp;.*
.*\.maxserving\..*
.*\.mb01\.com/.*
.*\.mbn\.com\.ua/.*
.*\.mediagridwork\.com/mx\.js.*
.*\.medialand\.ru/.*
.*\.mediaonenetwork\..*
.*\.mediaplex\..*
.*\.mediatarget\..*
.*\.mediavantage\..*
.*\.megaclick\.com/.*
.*\.mercuras\..*
.*\.metaffiliation\..*
.*\.microsoftaffiliates\..*\.aspx\?.*
.*\.mirago\.com/.*
.*\.miva\.com/.*
.*\.mochiads\.com/srv/.*
.*\.mootermedia\..*
.*\.msn\.com/\?adunitid.*
.*\.myway\.com/gca_iframe\..*
.*\.neoseeker\.com/.*_pc\.html.*
.*\.net3media\..*
.*\.netavenir\..*
.*\.newanglemedia\.com/clients/.*
.*\.news\.com\.au/.*-promo.*
.*\.newsadstream\..*
.*\.northmay\..*
.*\.ng/.*&amp;affiliate=.*
.*\.nwsource\..*/adv\.gif.*
.*\.nyadmcncserve-.*
.*\.obibanners\..*
.*\.othersonline\.com/partner/scripts/.*\?.*
.*\.onenetworkdirect\..*
.*\.openx\.org/a.*\.php.*
.*\.overture\..*
.*\.oxado\.com/.*
.*\.pc-ads\.com/.*
.*\.perfb\.com.*
.*\.pgpartner\..*
.*\.pheedo\..*/img\.phdo\?.*
.*\.php\?bannerid.*
.*\.php\?adclass.*
.*\.platinumadvertisement\..*
.*\.playertraffic\..*
.*\.pointroll\..*
.*\.predictad\..*
.*\.pricegrabber\..*
.*\.pricespy\.co\.nz/adds/.*
.*\.primaryads\..*
.*\.pro-advertising\..*
.*\.probannerswap\..*
.*\.profitpeelers\..*
.*\.projectwonderful\..*
.*\.proximic\.com/js/widget\.js.*
.*\.pulse360\..*
.*\.qksrv\.net/.*
.*\.qksz\.net/.*
.*\.questionmarket\..*
.*\.questus\.com/.*
.*\.realmatch\.com/Widgets/JS/.*
.*\.revresda\..*
.*\.rmxads\..*
.*\.rottentomatoes\..*size=.*x.*&amp;dechannel.*
.*\.rovion\..*\?AffID=.*
.*\.rwpads\..*
.*\.scanscout\..*
.*\.sevenload\.com/.*/endscreen\.swf.*
.*\.shareasale\..*
.*\.shareresults\..*
.*\.smartadserver\..*
.*\.smarttargetting\..*
.*\.snap\.com/.*
.*\.snopes\.com/.*/.*ad.*
.*\.socialmedia\.com/.*
.*\.sonnerie\..*
.*\.space\.com/promo/.*
.*\.sparkstudios\..*
.*\.specificclick\..*
.*\.specificmedia\..*
.*\.speedsuccess\.net/.*
.*\.sponsorpalace\..*
.*\.spotplex\..*widget.*
.*\.srtk\.net/.*
.*\.sta-ads\..*
.*\.survey-poll\..*
.*\.swf\?clickTag=.*
.*\.tacoda\..*
.*\.targetnet\..*
.*\.thebigchair\.com\.au/egnonline/.*
.*\.tiser\.com.*
.*\.tkqlhce\..*
.*\.total-media\.net/.*
.*\.tqlkg\.com.*
.*\.tradedoubler\..*
.*\.trafficmasterz\..*
.*\.trafic\..*
.*\.tremormedia\..*/AdManager@domain=~africam\.com.*
.*\.tribalfusion\..*
.*\.twinplan\.com/AF_.*
.*\.typepad\.com/sponsors/.*
.*\.tyroo\.com.*
.*\.uimserv\.net/.*
.*\.unicast\..*
.*\.universalhub\.com/bban/.*
.*\.usercash\.com/.*
.*\.utarget\..*
.*\.valuead\..*
.*\.valueclick\..*
.*\.vibrantmedia\..*
.*\.videoegg\.com/.*/init\.js\?.*
.*\.videosift\.com/bnr\.php\?.*
.*\.visitorglobe\..*record.*
.*\.vpico\.com/.*
.*\.webads\.co\.nz.*
.*\.webmasterplan\..*
.*\.widgetbucks\..*
.*\.worlddatinghere\..*
.*\.xchangebanners\..*
.*\.y\.megaclick\..*
.*\.yahoo\.com/ads\?.*=mrec_ad&amp;.*
.*\.yimg\.com/adv/.*
.*\.yimg\.com/.*/fairfax/.*
.*\.ytimg\.com/yt/swf/ad-.*\.swf.*
.*\.zanox\.com/.*
.*\.zangocash\..*/detectenvironment.*
.*\.zeads\.com/.*
.*\.zedo\.com/.*
.*\.zoomdirect\.com\.au/.*
.*/63\.225\.61\..*
.*/64\.73\.24\.44.*
.*/207\.67\.9\.41/.*
.*/213\.239\.222\.7/ad/.*
.*/217\.15\.94\.117.*
.*/468x60/.*
.*/\.adserv/.*
.*/a\.clearlightdigital\..*
.*/a\.collective-media\.net/.*
.*/a\.kerg\.net/.*
.*/a\.lakequincy\..*
.*/ab\.vcmedia\..*
.*/abmw\.aspx.*
.*/ad\.doubleclick\.net/ad/.*
.*/ad/code.*
.*/ad/view/.*
.*/ad\.asp\?.*
.*/ad\.aspx\?.*
.*/ad2\.aspx\?.*
.*/ad\.php\?.*
.*/ad/frame.*
.*/ad/header_.*
.*/ad/mercury.*
.*/ad/.*promo.*
.*/ad/serve.*
.*/ad/sponsors/.*
.*/ad/textlinks/.*
.*/ad_.*\.gif.*
.*/ad_.*
.*/ad_functions.*
.*/ad_insert\..*
.*/ad_manager\.js.*
.*/ad_refresher\..*
.*/ad_wrapper.*
.*/ad-frame\..*
.*/ad2games\..*
.*/adbanner.*
.*/adbrite.*
.*/adbrite\..*
.*/adclick.*
.*/adcode\.js.*
.*/adconfig/.*
.*/adconfig\.xml\?.*
.*/adcontent\..*
.*/adcycle/.*
.*/addyn.*
.*/adengage_.*
.*/adf\.cgi\?.*
.*/adfetch\?.*
.*/adframe\..*
.*/adframe_.*
.*/adfshow\?.*
.*/adgraphics/.*
.*/adheader.*
.*/adhoc/js/swfobject\.js.*
.*/adiframe/.*
.*/AdIFrame\..*
.*/adimages/.*
.*/adfunction.*
.*/adimage\..*
.*/adinsert\..*
.*/adjs\.php\?.*
.*/adjsmp\.php\?.*
.*/adlabel.*
.*/adlinks\.js.*
.*/adman/www/.*
.*/admanagement/.*
.*/admanager.*
.*/admatch-syndication\..*
.*/admedia\..*
.*/adn\.fusionads\..*
.*/adnetwork\..*
.*/adpage\..*
.*/adpeeps/.*
.*/adpeeps\.php.*
.*/Adplayer/.*
.*/adproducts/.*
.*/adproxy/.*
.*/adRelated\..*
.*/adrevolver/.*
.*/adroot/.*
.*/adrot\.js.*
.*/adserver/.*
.*/adsreporting/.*
.*/ads\.htm.*
.*/ads\.php\?.*
.*/ads_iframe\..*
.*/ads_reporting/.*
.*/ads_v2\.js.*
.*/ads_yahoo\..*
.*/ads.*\.php.*
.*/Ads-Leader.*
.*/Ads-Rec.*
.*/Ads-Sky.*
.*/ads2\.php\?.*
.*/ads2/.*
.*/ADSAdClient31\.dll\?GetAd\?PG=M.*
.*/adscript.*
.*/adsense_.*
.*/adsense\..*
.*/adserv.*/delivery/.*
.*/Adserver\?.*
.*/adServer\..*\?.*
.*/adsfolder/.*
.*/adshow\?.*
.*/AdsIframe/.*
.*/adsimage/.*
.*/AdsInclude\.js.*
.*/AdsManager/.*
.*/adsmanagement/.*\?.*
.*/adspace.*
.*/adspro/.*
.*/adsonar\..*
.*/adSwap\.js.*
.*/adsyndication\..*
.*/adtags/.*
.*/ADTECH;.*
.*/adtext\..*
.*/adtext_.*
.*/adtraff\..*
.*/adtype\.php\?.*
.*/advert_.*
.*/advert/ms.*
.*/adverti.*
.*/advertising/.*
.*/advertpro/.*
.*/adverts_.*
.*/adverts/.*
.*/adview\..*
.*/AdWorks/.*
.*/adwrapper/.*
.*/AdWrapperIframe\..*
.*/adxx\.php\?.*
.*/adx/fbnvideo/.*
.*/adx/fncvideo/.*
.*/affads/.*
.*/affiliate_.*
.*/affiliate.*/ad/.*
.*/AffiliateBanners/.*
.*/affiliates\.babylon\..*
.*/AffiliateWiz/.*
.*/afr\.php\?.*
.*/ah\.pricegrabber\.com/cb_table\.php.*
.*/aj\.600z\..*
.*/ajrotator/.*
.*/ajs\.php\?.*
.*/anchor\.captainad\..*
.*/annonser/.*
.*/api\.aggregateknowledge\..*
.*/aserve\.directorym\..*
.*/autoPromo.*
.*/banimpress\..*
.*/banman\.asp\?.*
.*/banman/.*
.*/banman\.isoftmarketing\..*
.*/banmanpro/.*&amp;ad.*
.*/banner.*ClickTag=.*
.*/banner/Ad.*
.*/banner_db\.php\?.*
.*/banner_ads\..*
.*/Banner_Management/.*
.*/banner\.php\?.*http.*
.*/banner_file\.php\?.*
.*/bannermanager/.*
.*/bannermedia/.*
.*/banners\?.*&amp;.*
.*/banners/.*
.*/banners/banners\.jsp\?.*
.*/banners\.adultfriendfinder.*
.*/banners\.empoweredcomms\..*
.*/banners/.*\.gif.*
.*/BannerServer/.*
.*/bannerview\..*\?.*
.*/bannery/.*\?banner=.*
.*/bbccom\.js\?.*
.*/bbc\.com/script/1/config\.js.*
.*/bin-layer\..*
.*/blogad_.*
.*/blogads.*
.*/bmp/banman\.asp\?.*
.*/bnrsrv\..*\?.*
.*/boylesportsreklame\..*\?.*
.*/bs\.yandex\.ru.*
.*/c\.adroll\..*
.*/cas\.clickability\.com/.*
.*/clickserv.*
.*/cm8adam.*
.*/cm8space_call.*
.*/cms/Profile_Display/.*
.*/cnnSLads\.js.*
.*/cnwk\..*widgets\.js.*
.*/commercials/splash.*
.*/content\.4chan\.org/tmp/.*
.*/content\.yieldmanager\..*
.*/ContextAd\..*
.*/csDynamic.*
.*/CTAMlive160x160\..*
.*/ctxtlink/.*
.*/d\.m3\.net/.*
.*/d1\.openx\.org/.*&amp;block=.*
.*/da\.feedsportal\.com/r/.*
.*/data\.resultlinks\..*
.*/de.*\.myspace\..*
.*/delivery\.3rdads\..*
.*/descPopup\.js.*
.*/destacados/.*
.*/direct_ads\..*
.*/directads\..*
.*/dontblockthis/.*
.*/DisplayAds.*
.*/DNSads\.html\?.*
.*/dsg/bnn/.*
.*/DynamicAd\?.*
.*/DynamicCSAd\?.*
.*/DynamicVideoAd\?.*&amp;.*
.*/dynBanner/flash/.*
.*/e\.yieldmanager\.net/script\.js.*
.*/eBayISAPI\.dll\?EKServer&amp;.*
.*/ecustomeropinions\.com/popup/.*
.*/ekmas\.com.*
.*/ERALinks/.*
.*/export_feeds\.php\?.*&amp;banner.*
.*/external/ad\.js.*
.*/eyoob\.com/elayer/.*
.*/fairadsnetwork\..*
.*/flashAds\..*
.*/flashbanner/.*
.*/flipmedia.*
.*/forms\.aweber\..*
.*/freetrafficbar\..*
.*/fuseads/.*
.*/gamecast/ads.*
.*/gamersad\..*
.*/gampad/google_service\.js.*
.*/get\.lingospot\..*
.*/getad\.php.*
.*/getad\.php\?.*
.*/get_ad\.php\?.*
.*/getbanner\.cfm\?.*
.*/google_ads/.*
.*/google-adsense.*
.*/googleAd\.js.*
.*/googleframe\..*
.*/hits\.europuls\..*
.*/hits4pay\..*
.*/hotjobs_module\.js.*
.*/houseads/.*
.*/html\.ng/.*
.*/httpads/.*
.*/iframe_ad\..*
.*/iframe-ads/.*
.*/iframead\..*
.*/iframed_.*sessionid=.*
.*/images/ad/.*
.*/images/bnnrs/.*
.*/images/promo/player.*
.*/img\.shopping\.com/sc/pac/shopwidget_.*
.*/index_files/.*\.htm.*
.*/IndianRailways/.*
.*/intext\.js.*
.*/invideoad\..*
.*/itunesaffiliate.*
.*/job_ticker\..*
.*/js\..*\.yahoo\.net/iframe\.php\?.*
.*/js/interstitial_space\.js.*
.*/js/ysc_csc_.*
.*/js\.ng/site=.*
.*/kermit\.macnn\..*
.*/kestrel\.ospreymedialp\..*
.*/l\.yimg\.com/a/a/1-/flash/promotions/.*/0.*
.*/l\.yimg\.com/a/a/1-/java/promotions/.*\.swf.*
.*/launch/testdrive\.gif.*
.*/layer-ads\..*
.*/layerads_.*
.*/LinkExchange/.*
.*/linkreplacer\.js.*
.*/linkshare/.*
.*/listings\..*/iFrame/Dir.*
.*/logos/adLogo.*
.*/lw/ysc_csc_.*
.*/MarbachAdverts\..*
.*/marketing.*partner.*
.*/mac-ad\?.*
.*/magic-ads/.*
.*/media\.funpic\..*/layer\..*
.*/mediamgr\.ugo\..*
.*/medrx\.sensis\.com\.au/.*
.*/miva_ads\..*
.*/MNetOrfad\.js.*
.*/mod_ad/.*
.*/mtvmusic_ads_reporting\.js.*
.*/nascar/.*/defector\.js.*
.*/nascar/.*/promos/.*
.*/network\.sportsyndicator\..*
.*/network\.triadmedianetwork\..*
.*/oas_logic\..*
.*/oasc03\..*
.*/oasisi\.php\?.*
.*/oasisi-.*\.php\?.*
.*/obeus\.com/initframe/.*
.*/openads/.*\?.*
.*/openads2/.*
.*/openx/www/.*
.*/outsidebanners/.*
.*/overture/.*
.*/overture_.*
.*/ox\.bit-tech\.net/delivery/.*
.*/pagead/.*&amp;videoad_start_delay=1.*
.*/pagead/ads\?video_url_to_fetch=.*
.*/pagead/imgad\?.*
.*/pageear/.*
.*/pageear\.js.*
.*/pagepeel.*
.*/partner.*rotate.*
.*/partner\.gonamic\.de/Affiliate/.*
.*/partner\.sbaffiliates\..*
.*/partner\.video\.syndication\.msn\.com/.*
.*/partners/.*
.*/partnership/.*affiliate.*
.*/peel\.js.*
.*/peel1\.js.*
.*/peelad/.*
.*/perfads\.js\?.*
.*/performancingads/.*
.*/pfadx/.*\.mtvi/video;.*
.*/pfadx/comedycentral\..*
.*/phpads/.*
.*/phpads2/.*
.*/phpadserver/.*
.*/pilot_ad\..*
.*/play/ad/.*
.*/player/ad\.htm.*
.*\.plsthx\.com/newaff/.*
.*/podimages/.*
.*/popAds\.js.*
.*/popupjs\..*
.*/processing/impressions \.asp\?.*
.*/promoboxes/.*
.*/promos/.*banner\.gif.*
.*/promos\.fling\..*
.*/printads/.*
.*/psclicks\.asp\?.*
.*/public/ad\?.*
.*/public/bannerjs\..*\?.*=.*
.*/public\.zangocash\..*
.*/publisher\.shopzilla\..*
.*/r\.mail\.ru.*
.*/rad\..*\?GetSAd=.*
.*/reclame/ad\..*
.*/RequestAdvertisement\..*
.*/resources\.infolinks\..*
.*/rhs_promo_.*
.*/rok\.com\.com/.*
.*/rotateAds\..*
.*/rotating_banner.*
.*/rotating\.php.*
.*/rotation/.*\.php\?.*
.*/rover\.ebay\..*&amp;campid=.*
.*/rtq\.careerbuilder\..*
.*/s3\.buysellads\..*
.*/s7121\.vsservers\..*
.*/scripts\.snowball\.com/clinkscontent/.*
.*/search\.spotxchange\.com/.*
.*/shared/promos/.*
.*/show\.asp\?.*_sky.*
.*/show_ad\.ashx\?.*
.*/show_ad_.*
.*/show_afs_ads\.js.*
.*/show_deals\.js.*
.*/show_i\.php\?.*
.*/showad\..*
.*/showads\..*
.*/showbanner\.php\?.*
.*/ShowFlashAd\..*
.*/skyad\.php.*
.*/slideInAd\.js.*
.*/small_ad\..*
.*/socialads\.js.*
.*/softsale/.*
.*/Splash/Page_Header/.*
.*/spinbox\.freedom\..*
.*/sponsImages/.*
.*/sponsorad\..*
.*/sponsored.*
.*/sponsored\.gif.*
.*/squaread\..*
.*/static\.zangocash\..*
.*/support\.biemedia\..*
.*/surveyCookie\.js.*
.*/svgn\.com/.*
.*/testingad\..*
.*/textad\?.*
.*/textAd\..*
.*/tii_ads\.js.*
.*/tikilink\?.*
.*/tizes/a\.aspx\?.*
.*/tmz-adblock/.*
.*/trusearch\.net/affblock/.*
.*/ttz_ad\.js.*
.*/unicast\.ign\.com/assets/.*
.*/upsellitJS2\.jsp\?.*
.*/userbanners/.*
.*/valueclick\..*
.*/vendshow/.*
.*/video\.ap\.org/.*/ad_js\..*
.*/video-cdn\..*_ad_.*
.*/video-cdn\..*_promo_.*
.*/videoad\..*
.*/videoads\..*
.*/videoads/.*
.*/vindicoasset\..*/INSTREAMAD/.*
.*/visit\.homepagle\..*
.*/w1\.buysub\..*
.*/web\.lightningcast\.net/servlets/getPlaylist\?.*
.*/webadImg/.*
.*/webads_.*
.*/whiteglove\.jsp\?.*
.*/widget\.blogrush\.com/show\.js.*
.*/ws\.amazon\..*/widgets/q\?.*
.*/www/delivery/.*
.*/ygames_e/embed/src/embedPlayer\.js.*
.*/ysmads\.html.*
.*//wrapper\.3dgamers\..*
http://171\.66\.124\.80/.*
http://196\.41\.0\.207/.*
http://72\.32\.71\.244.*
http://a\.ads\..*
http://ad.*\.emidiate\..*
http://abm\.hothardware\..*
http://ad-uk\..*
http://ad\..*
http://ad0\..*
http://ad1\..*
http://ad2\..*
http://adbureau\..*
http://adclient.*
http://adcreative\..*
http://adfarm\..*
http://adimg\..*
http://adimages\..*
http://adinterax\..*
http://adnet\..*
http://adonline\..*
http://adq\..*
http://adremote\..*
http://ads\..*
http://ads1\..*
http://ads2\..*
http://ads3\..*
http://ads4\..*
http://ads5\..*
http://adsatt\..*
http://adsearch\..*
http://adserv.*
http://adsnew\..*
http://adsremote\..*
http://adstream\..*\.cgi.*
http://adsvr\..*
http://adsys\..*
http://adt\..*
http://adtags\..*
http://adtech\..*
http://adtology.*
http://adv\..*
http://advert\..*
http://adverts\..*
http://advision\..*/getad.*
http://adworks\..*
http://adx\..*
http://affiliates\..*\.aspx\?.*
http://afimages\..*
http://almobty\.com/.*
http://altfarm\..*
http://avpa\..*
http://banner\..*
http://banners.*&amp;Random=.*
http://banners\..*http.*
http://biz28\..*
http://body\.imho\.ru/.*
http://bwp\..*
http://cbanners\..*
http://cdn\.nvero\..*
http://circads\..*
http://common\..*/slider\.js.*
http://dclk\..*\.ng/.*
http://feeds\..*/~a/.*
http://fdads\.sv\..*
http://ffxcam\..*
http://getad\..*
http://images\..*/banners/.*
http://jazad\..*
http://lads\..*-gutter-.*
http://mads\..*
http://marketing\..*http.*
http://ng3\.ads\..*
http://oas-central\..*
http://pagead2\..*
http://promo2\..*
http://rcm.*\.amazon\..*
http://reklama\..*
http://richmedia2\..*
http://rss\..*/~a/.*
http://servedbyadbutler\..*
http://smartad\..*
http://stocker\.bonnint\..*
http://synad.*
http://ttsrc\.aroq\..*
http://video\.flashtalking\..*
http://wrapper\..*/a\?.*
http://xban\..*/banners/.*
http://.*/partners\..*
https://en\.wikipedia\.org/w/load\.php\?lang=en&amp;modules=ext\.3d\.styles%7Cext\.uls\.interlanguage%7Cext\.visualEditor\.desktopArticleTarget\.noscript%7Cext\.wikimediaBadges%7Cmediawiki\.legacy\.commonPrint%2Cshared%7Cmediawiki\.skinning\.interface%7Cskins\.vector\.styles&amp;only=styles&amp;skin=vector
https://en\.wikipedia\.org/w/load\.php\?lang=en&amp;modules=site\.styles&amp;only=styles&amp;skin=vector</property>
  </property>
</object>
