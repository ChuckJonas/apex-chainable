import { ChainJob, ChainProps, DateDisplay } from '@src/components';
import { ChainableLink } from '@src/generated';
import * as norm from '@src/lib/normalized';
import { listenToUpdates } from '@src/lib/streaming';
import { Card, Col, Collapse, Icon, Layout, Row } from 'antd';
import * as React from 'react';
import { hot } from 'react-hot-loader';
import { CompositeCollection, generateSelect, Rest } from 'ts-force';

interface IAppState {
  chainLinks: Normalized<ChainableLink>;
}

class App extends React.Component<{}, IAppState> {

  constructor(props: IAppState) {
    super(props);

    this.state = {
      chainLinks: norm.empty(),
    };
  }

  public componentDidMount() {
    ChainableLink.retrieve(
      `SELECT ${generateSelect(Object.values(ChainableLink.FIELDS))}
      FROM ${ChainableLink.API_NAME}
      ORDER BY CreatedDate DESC LIMIT 1000`,
    ).then((links) => {
      const chainLinks = norm.fromArray(links, (obj) => obj.id);
      this.setState({ chainLinks });
    });

    listenToUpdates((newChain) => {
      const chainLinks = norm.addItem(this.state.chainLinks, 'id', newChain);
      this.setState({ chainLinks });
    });
  }

  public renderChainHeader = (chain: ChainProps) => {
    const style: React.CSSProperties = { float: 'right', fontSize: 20, marginRight: 25 };
    const icon = chain.completed ?
      <Icon style={style} type='check-circle' /> :
      <Icon style={style} type='exclamation-circle-o' />;

    return (
      <div>
        <Row type='flex' justify='space-between'>
          <Col span={6}>{chain.links[0].actionType} </Col>
          <Col span={3}>links: {chain.links.length}{icon}</Col>
        </Row>
        <Row type='flex' justify='space-between'>
          <Col span={6}> {chain.processKey}</Col>
          <Col span={3}><DateDisplay date={chain.created} /></Col>
        </Row>
      </div>

    );
  }

  public render() {
    const chains = this.processLinks();
    const chainsEl = chains.map((chain) => {
      return (
        <Collapse.Panel header={this.renderChainHeader(chain)} key={chain.processKey} >
          <ChainJob {...chain} />
        </Collapse.Panel>
      );
    });

    return (
      <Layout>
        <Layout.Content>
          <Card title='Chain Jobs'>
            <Collapse>
              {chainsEl}
            </Collapse>
          </Card>
        </Layout.Content>
      </Layout>
    );
  }

  private processLinks = () => {
    const chainMap = new Map<string, ChainableLink[]>();
    norm.forEach(this.state.chainLinks, (link) => {
      if (chainMap.has(link.key)) {
        chainMap.get(link.key).push(link);
      } else {
        chainMap.set(link.key, [link]);
      }
    });

    const chains: ChainProps[] = [];

    chainMap.forEach((links, processKey) => {
      links = links.sort((a, b) => a.linkPosition - b.linkPosition);
      const chain: ChainProps = {
        processKey,
        links,
        created: links[0].createdDate,
        started: links[0].executedDate,
        finished: links[links.length - 1].executedDate,
        completed: links[links.length - 1].executedDate != null,
      };
      chains.push(chain);
    });

    return chains;
  }

}

export default hot(module)(App);
