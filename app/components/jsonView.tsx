import { Divider } from 'antd';
import * as React from 'react';
import ReactJson from 'react-json-view';

export interface JSONViewProps {
  title: string;
  json: string | object;
}

export class JSONView extends React.Component<JSONViewProps> {

  constructor(props: JSONViewProps) {
    super(props);
  }

  public renderJsonOrPre = () => {
    const jsonObj = this.props.json;
    let json;
    if (typeof this.props.json === 'string') {
      try {
        json = JSON.parse(this.props.json);
      } catch (e) {
        return <pre>{jsonObj}</pre>;
      }
    } else {
      json = jsonObj;
    }
    return <ReactJson name={null} indentWidth={3} displayDataTypes={false} collapsed={true} src={json} />;
  }

  public render() {
    if (!this.props.json) {
      return null;
    }
    return (
      <div>
        <Divider orientation='left'>{this.props.title}</Divider>
        {this.renderJsonOrPre()}
      </div>
    );
  }
}
