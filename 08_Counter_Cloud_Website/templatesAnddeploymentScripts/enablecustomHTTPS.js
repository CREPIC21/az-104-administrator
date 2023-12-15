const { CdnManagementClient } = require("@azure/arm-cdn");
const { DefaultAzureCredential } = require("@azure/identity");

/**
 * This sample demonstrates how to Enable https delivery of the custom domain.
 *
 * @summary Enable https delivery of the custom domain.
 * x-ms-original-file: specification/cdn/resource-manager/Microsoft.Cdn/stable/2023-05-01/examples/CustomDomains_EnableCustomHttpsUsingCDNManagedCertificate.json
 */
async function customDomainsEnableCustomHttpsUsingCdnManagedCertificate() {
    const subscriptionId = process.argv[2];
    const resourceGroupName = process.argv[3];
    const profileName = process.argv[4];
    const endpointName = process.argv[5];
    const customDomainName = process.argv[6];
    const credential = new DefaultAzureCredential();
    const client = new CdnManagementClient(credential, subscriptionId);
    const result = await client.customDomains.beginEnableCustomHttpsAndWait(
        resourceGroupName,
        profileName,
        endpointName,
        customDomainName
    );
    console.log(result);
}

customDomainsEnableCustomHttpsUsingCdnManagedCertificate();