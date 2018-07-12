$(() => {
  $('.filter-letter').on('click', e => {
    const $el = $(e.target);
    const isActive = $el.hasClass('active');
    let filter = '';

    $('.filter-letter').removeClass('active');

    if (!isActive) {
      $el.addClass('active');
      filter = $el.text();
    }

    refresh_users(filter);
  });

  $('.buybutton').on('click', e => {
    const $el = $(e.currentTarget.parentElement.parentElement);
    $el.addClass('ignoreclicks');
  });

  function refresh_users(filter) {
    $('#user_preview *').show();
    if(filter !== ''){
      $(`#user_preview .User:not(div[data-name^='${filter}'])`).hide();
    }
  }
});
