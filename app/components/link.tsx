import { DateDisplay, JSONView } from '@src/components';
import { ChainableLinkFields } from '@src/generated';
import { Card, Form, List } from 'antd';
import * as React from 'react';
import ReactJson from 'react-json-view';

interface ChainLinkProps {
  link: ChainableLinkFields;
}

export class ChainLink extends React.Component<ChainLinkProps> {

  constructor(props: ChainLinkProps) {
    super(props);
  }

  public render() {
    let response;
    try {
      response = <ReactJson src={JSON.parse(this.props.link.response)} />;
    } catch (e) {}
    return (
      <div>
        <Form layout='inline'>
          <Form.Item label='Job' >{this.props.link.name}</Form.Item>
          <Form.Item label='Executed' ><DateDisplay date={this.props.link.executedDate} /></Form.Item>
          <Form.Item label='Continue on Exception' >{this.props.link.continueonException ? 'YES' : 'NO'}</Form.Item>
          <Form.Item label='RollBack on Exception' >{this.props.link.rollbackonException ? 'YES' : 'NO'}</Form.Item>
        </Form>
        <JSONView json={this.props.link.actionData} title='Action Data'/>
        <JSONView json={this.props.link.response} title='Response'/>
        <JSONView json={this.props.link.error} title='Error'/>

      </div>
    );
  }
}
