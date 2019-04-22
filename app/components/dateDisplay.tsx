import * as React from 'react';

export interface DateDisplayProps {
  date: Date;
}

export class DateDisplay extends React.Component<DateDisplayProps> {

  constructor(props: DateDisplayProps) {
    super(props);
  }

  public render() {
    if (!this.props.date) {
      return null;
    }
    return (
      <span>{this.props.date.toLocaleDateString()} - {this.props.date.toLocaleTimeString()}</span>
    );
  }
}
