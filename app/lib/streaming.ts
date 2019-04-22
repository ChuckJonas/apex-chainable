import { ChainableLink } from '@src/generated';
import { Rest } from 'ts-force';
import { DEFAULT_CONFIG } from 'ts-force/build/auth/baseConfig';

export interface CometMessage {
  event: { createdDate: Date, replayId: number, type: string };
  sobject: { Id: string };
}

// PushTopic pushTopic = new PushTopic();
// pushTopic.ApiVersion = 42.0;
// pushTopic.Name = 'Chainables';
// pushTopic.Description = 'Chainable Link Notifications';
// pushTopic.Query = 'SELECT Id, Name FROM Chainable_Link__c';
// insert pushTopic;
// https://github.com/cometd/cometd-documentation/blob/master/src/main/asciidoc/javascript_transports.adoc
export const listenToUpdates = (handleUpdate: (newItem: ChainableLink) => void) => {

  // Create the CometD object.
  // doesn't work with CORS
  const lib = require('cometd');
  // if (process.env === 'production') {
  const cometd = new lib.CometD();

  // Configure the CometD object.
  cometd.configure({
    url: `${DEFAULT_CONFIG.instanceUrl}/cometd/42.0/`,
    requestHeaders: { Authorization: `OAuth ${DEFAULT_CONFIG.accessToken}` },
    appendMessageTypeToURL: false,
  });

  // Handshake with the server.
  cometd.handshake((handshakeResp: any) => {
    if (handshakeResp.successful) {
      // Subscribe to receive messages from the server.
      cometd.subscribe('/topic/Chainables', function(m: any) {
        const dataFromServer: CometMessage = m.data;
        if (dataFromServer.event.type === 'created' || dataFromServer.event.type === 'updated') {
          new ChainableLink({ id: dataFromServer.sobject.Id }).refresh().then((newValue) => {
            handleUpdate(newValue);
          });
        }
      });
    }
  });
  // }
};
