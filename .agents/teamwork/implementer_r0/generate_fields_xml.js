const fs = require('fs');
const path = require('path');

function escapeXml(unsafe) {
  if (unsafe === null || unsafe === undefined) return '';
  return String(unsafe)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&apos;');
}

const rawDir = path.join(__dirname, 'raw_metadata');
const targetDir = path.resolve(__dirname, '../../../force-app/main/default/objects/LearningProgram/fields');

const files = fs.readdirSync(rawDir).filter(f => f.endsWith('.json'));

for (const file of files) {
  const content = JSON.parse(fs.readFileSync(path.join(rawDir, file), 'utf8'));
  const devName = content.DeveloperName;
  const m = content.Metadata;
  const fullName = `${devName}__c`;
  const type = m.type;

  let xml = '<?xml version="1.0" encoding="UTF-8"?>\n';
  xml += '<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">\n';
  xml += `    <fullName>${fullName}</fullName>\n`;

  if (m.defaultValue !== null && m.defaultValue !== undefined) {
    xml += `    <defaultValue>${escapeXml(m.defaultValue)}</defaultValue>\n`;
  }
  if (m.deleteConstraint) {
    xml += `    <deleteConstraint>${escapeXml(m.deleteConstraint)}</deleteConstraint>\n`;
  }
  if (m.deprecated !== null && m.deprecated !== undefined) {
    xml += `    <deprecated>${m.deprecated}</deprecated>\n`;
  }
  if (m.description) {
    xml += `    <description>${escapeXml(m.description)}</description>\n`;
  }
  if (m.externalId) {
    xml += `    <externalId>${m.externalId}</externalId>\n`;
  }
  if (m.inlineHelpText) {
    xml += `    <inlineHelpText>${escapeXml(m.inlineHelpText)}</inlineHelpText>\n`;
  }
  if (m.label) {
    xml += `    <label>${escapeXml(m.label)}</label>\n`;
  }
  if (m.length) {
    xml += `    <length>${m.length}</length>\n`;
  }
  if (m.precision) {
    xml += `    <precision>${m.precision}</precision>\n`;
  }
  if (m.referenceTo) {
    xml += `    <referenceTo>${escapeXml(m.referenceTo)}</referenceTo>\n`;
  }
  if (m.relationshipLabel) {
    xml += `    <relationshipLabel>${escapeXml(m.relationshipLabel)}</relationshipLabel>\n`;
  }
  if (m.relationshipName) {
    xml += `    <relationshipName>${escapeXml(m.relationshipName)}</relationshipName>\n`;
  }
  if (type !== 'Checkbox' && m.required !== null && m.required !== undefined) {
    xml += `    <required>${m.required}</required>\n`;
  }
  if (m.scale !== null && m.scale !== undefined) {
    xml += `    <scale>${m.scale}</scale>\n`;
  }

  // Always enable trackHistory for all target fields!
  xml += '    <trackHistory>true</trackHistory>\n';
  xml += `    <type>${type}</type>\n`;

  if (m.unique) {
    xml += `    <unique>${m.unique}</unique>\n`;
  }

  if (m.valueSet && m.valueSet.valueSetDefinition) {
    const vsd = m.valueSet.valueSetDefinition;
    xml += '    <valueSet>\n';
    if (m.valueSet.restricted !== null && m.valueSet.restricted !== undefined) {
      xml += `        <restricted>${m.valueSet.restricted}</restricted>\n`;
    }
    xml += '        <valueSetDefinition>\n';
    xml += `            <sorted>${vsd.sorted || false}</sorted>\n`;
    if (Array.isArray(vsd.value)) {
      for (const val of vsd.value) {
        xml += '            <value>\n';
        xml += `                <fullName>${escapeXml(val.valueName || val.fullName)}</fullName>\n`;
        xml += `                <default>${val.default || false}</default>\n`;
        xml += `                <label>${escapeXml(val.label || val.valueName)}</label>\n`;
        xml += '            </value>\n';
      }
    }
    xml += '        </valueSetDefinition>\n';
    xml += '    </valueSet>\n';
  }

  xml += '</CustomField>\n';

  const outFilePath = path.join(targetDir, `${fullName}.field-meta.xml`);
  fs.writeFileSync(outFilePath, xml, 'utf8');
  console.log(`Generated ${fullName}.field-meta.xml`);
}

console.log('All XML files generated.');
