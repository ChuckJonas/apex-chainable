import { ChainLink, DateDisplay } from '@src/components';
import { ChainableLink } from '@src/generated';
import { Badge, Card, Collapse, Divider, Form, List } from 'antd';
import * as React from 'react';

export interface ChainProps {
  processKey: string;
  created: Date;
  started: Date;
  finished: Date;
  completed: boolean;
  links: ChainableLink[];
}

export class ChainJob extends React.Component<ChainProps> {

  constructor(props: ChainProps) {
    super(props);
  }

  public renderLinks = () => {
    return this.props.links.map((link) => {

      let badgeStyle: any = { backgroundColor: '#52c41a' };
      if (link.error) {
        badgeStyle.backgroundColor = 'red';
      } else if (!link.executedDate) {
        badgeStyle = { backgroundColor: '#fff', color: '#999', boxShadow: '0 0 0 1px #d9d9d9 inset' };
      }

      return (
        <Collapse.Panel
          key={link.linkPosition.toString()}
          header={<span><Badge showZero={true} count={link.linkPosition} style={badgeStyle} /> {link.actionType}</span>}
        >
          <ChainLink link={link} />
        </Collapse.Panel>
      );
    });
  }

  public render() {
    return (
        <div>
          <Collapse>
            {this.renderLinks()}
          </Collapse>
        </div>
    );
  }
}
