---
title: Post
---

This is the abstract parent type of [StatusMessage][status_message] and currently still [Reshare][reshare].

{% include warning_box.html
   title="Future of reshares"
   content="<p>Reshare will not inherit from Post in the future anymore! More information about this
   can be found <a href=\"/diaspora_federation/entities/reshare.html\">here</a> or
   in <a href=\"https://github.com/diaspora/diaspora_federation/issues/83\">this issue</a>.</p>"
%}

## Common Properties

| Property     | Type (Length)                | Description                                  |
| ------------ | ---------------------------- | -------------------------------------------- |
| `author`     | [diaspora\* ID][diaspora-id] | The diaspora\* ID of the author of the post. |
| `guid`       | [GUID][guid]                 | The GUID of the post.                        |
| `created_at` | [Timestamp][timestamp]       | The create timestamp of the post.            |
| `public`     | [Boolean][boolean]           | `true` if the post is public.                |

## Common Optional Properties

| Property                | Type (Length)          | Description                                        |
| ----------------------- | ---------------------- | -------------------------------------------------- |
| `provider_display_name` | [String][string] (255) | The means by which the author has posted the post. |

[diaspora-id]: {{ site.baseurl }}/federation/types.html#diaspora-id
[guid]: {{ site.baseurl }}/federation/types.html#guid
[timestamp]: {{ site.baseurl }}/federation/types.html#timestamp
[boolean]: {{ site.baseurl }}/federation/types.html#boolean
[string]: {{ site.baseurl }}/federation/types.html#string
[status_message]: {{ site.baseurl }}/entities/status_message.html
[reshare]: {{ site.baseurl }}/entities/reshare.html
