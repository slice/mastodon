import React from 'react';
import PropTypes from 'prop-types';
import { defineMessages } from 'react-intl';
import classNames from 'classnames';

const messages = defineMessages({
  search: { id: 'lists.search', defaultMessage: 'Search among people you follow' },
});

export default class Search extends React.PureComponent {

  static propTypes = {
    intl: PropTypes.object.isRequired,
    value: PropTypes.string.isRequired,
    onChange: PropTypes.func.isRequired,
    onSubmit: PropTypes.func.isRequired,
    onClear: PropTypes.func.isRequired,
  };

  handleChange = e => {
    this.props.onChange(e.target.value);
  }

  handleKeyUp = e => {
    if (e.keyCode === 13) {
      this.props.onSubmit(this.props.value);
    }
  }

  handleClear = () => {
    this.props.onClear();
  }

  render () {
    const { value, intl } = this.props;
    const hasValue = value.length > 0;

    return (
      <div className='list-editor__search search'>
        <label>
          <span style={{ display: 'none' }}>{intl.formatMessage(messages.search)}</span>

          <input
            className='search__input'
            type='text'
            value={value}
            onChange={this.handleChange}
            onKeyUp={this.handleKeyUp}
            placeholder={intl.formatMessage(messages.search)}
          />
        </label>

        <div role='button' tabIndex='0' className='search__icon' onClick={this.handleClear}>
          <i className={classNames('fa fa-search', { active: !hasValue })} />
          <i aria-label={intl.formatMessage(messages.search)} className={classNames('fa fa-times-circle', { active: hasValue })} />
        </div>
      </div>
    );
  }

}
