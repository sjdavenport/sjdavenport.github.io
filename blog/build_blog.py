"""
Build the blog: converts markdown posts in blog/posts/ into HTML pages
and regenerates blog/index.html.

Usage: python3 build_blog.py   (requires: uv pip install markdown)

Each post is a markdown file in blog/posts/ named YYYY-MM-DD-slug.md with
front matter:

    ---
    title: My Post Title
    ---

    Post content in markdown...

The date is taken from the filename. Output goes to blog/<slug>/index.html
and the post list at blog/index.html is rebuilt (newest first).
"""
import os
import re
from datetime import datetime

import markdown

BLOG_DIR = os.path.dirname(os.path.abspath(__file__))
POSTS_DIR = os.path.join(BLOG_DIR, 'posts')

HEAD = """<!DOCTYPE html>
<html lang="en-us">
<head>

<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="theme" content="hugo-academic">
<meta name="author" content="Samuel Davenport">

<meta name="description" content="Samuel Davenport's blog">

<meta name="theme-color" content="#0095eb">

<link rel="stylesheet" href="//cdnjs.cloudflare.com/ajax/libs/highlight.js/9.12.0/styles/github.min.css">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/3.3.7/css/bootstrap.min.css" integrity="sha512-6MXa8B6uaO18Hid6blRMetEIoPqHf7Ux1tnyIQdpt9qI5OACx7C+O3IVTr98vwGnlcg0LOLa02i9Y1HpVhlfiw==" crossorigin="anonymous">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css" integrity="sha512-SfTiTlX6kk+qitfevl/7LibUOeJWlt9rbyDn92a1DqWOw9vWG2MFoays0sgObmWazO5BQPiFucnnEAjpAB+/Sw==" crossorigin="anonymous">

<link rel="stylesheet" href="//fonts.googleapis.com/css?family=Playfair&#43;Display:400,700%7cFauna&#43;One">

<link rel="stylesheet" href="/styles.css">

<link rel="manifest" href="/site.webmanifest">
<link rel="icon" type="image/png" href="/img/icon.png">
<link rel="apple-touch-icon" type="image/png" href="/img/icon-192.png">

<link rel="canonical" href="https://sjdavenport.github.io{url}">

<title>{title} | Samuel Davenport</title>

</head>
<body id="top">

<nav class="navbar navbar-default navbar-fixed-top" id="navbar-main">
<div class="container">

<div class="navbar-header">

<button type="button" class="navbar-toggle collapsed" data-toggle="collapse"
data-target=".navbar-collapse" aria-expanded="false">
<span class="sr-only">Toggle navigation</span>
<span class="icon-bar"></span>
<span class="icon-bar"></span>
<span class="icon-bar"></span>
</button>

<a class="navbar-brand" href="/">Samuel Davenport</a>
</div>

<div class="collapse navbar-collapse">

<ul class="nav navbar-nav navbar-right">
<li class="nav-item">
<a href="/#about">

<span>Home</span>

</a>
</li>

<li class="nav-item">
<a href="/research/">

<span>Research</span>

</a>
</li>

<li class="nav-item">
<a href="/software/">

<span>Software</span>

</a>
</li>

<li class="nav-item">
<a href="/talks/">

<span>Talks</span>

</a>
</li>

<li class="nav-item">
<a href="/blog/">

<span>Blog</span>

</a>
</li>
</ul>

</div>
</div>
</nav>

"""

FOOT = """
<footer class="site-footer">
<div class="container">
<p class="powered-by">

&copy; 2018 &middot;

Powered by the
<a href="https://sourcethemes.com/academic/" target="_blank" rel="noopener">Academic theme</a> for
<a href="https://gohugo.io" target="_blank" rel="noopener">Hugo</a>.
Thanks to Jeremias Knoblauch at the University of Warwick for providing this website template.

<span class="pull-right" aria-hidden="true">
<a href="#" id="back_to_top">
<span class="button_icon">
<i class="fa fa-chevron-up fa-2x"></i>
</span>
</a>
</span>

</p>
</div>
</footer>

<script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.2.1/jquery.min.js" integrity="sha512-3P8rXCuGJdNZOnUx/03c1jOTnMn3rP63nBip5gOP2qmUh5YAdVAvFZ1E+QLZZbC1rtMrQb+mah3AfYW11RUrWA==" crossorigin="anonymous"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/3.3.7/js/bootstrap.min.js" integrity="sha512-iztkobsvnjKfAtTNdHkGVjAYTrrtlC7mGp/54c40wowO7LhURYl3gVzzcEqGl/qKXQltJ2HwMrdLcNUdo+N/RQ==" crossorigin="anonymous"></script>
<script src="//cdnjs.cloudflare.com/ajax/libs/highlight.js/9.12.0/highlight.min.js" integrity="sha256-/BfiIkHlHoVihZdc6TFuj7MmJ0TWcWsMXkeDFwhi0zw=" crossorigin="anonymous"></script>
<script>hljs.initHighlightingOnLoad();</script>

</body>
</html>
"""

COMMENTS = """
<hr>
<h3>Comments</h3>
<script src="https://utteranc.es/client.js"
        repo="sjdavenport/sjdavenport.github.io"
        issue-term="pathname"
        label="blog-comment"
        theme="github-light"
        crossorigin="anonymous"
        async>
</script>
"""


def parse_post(path):
    """Return a dict with title, date, slug and html content for one post."""
    fname = os.path.basename(path)
    m = re.match(r'(\d{4}-\d{2}-\d{2})-(.+)\.md$', fname)
    if not m:
        raise ValueError(f'post filename must be YYYY-MM-DD-slug.md, got {fname}')
    date = datetime.strptime(m.group(1), '%Y-%m-%d')
    slug = m.group(2)

    with open(path) as f:
        text = f.read()

    title = slug.replace('-', ' ').title()
    fm = re.match(r'---\s*\n(.*?)\n---\s*\n', text, re.DOTALL)
    if fm:
        for line in fm.group(1).splitlines():
            if line.startswith('title:'):
                title = line.split(':', 1)[1].strip()
        text = text[fm.end():]

    html = markdown.markdown(text, extensions=['fenced_code', 'tables'])

    excerpt = ''
    m = re.search(r'<p>(.*?)</p>', html, re.DOTALL)
    if m:
        excerpt = re.sub(r'<[^>]+>', '', m.group(1)).replace('\n', ' ')
        words = excerpt.split()
        if len(words) > 40:
            excerpt = ' '.join(words[:40]) + ' &hellip;'

    return {'title': title, 'date': date, 'slug': slug, 'html': html,
            'excerpt': excerpt}


def build_post_page(post):
    url = f'/blog/{post["slug"]}/'
    page = HEAD.format(title=post['title'], url=url)
    page += f"""
<div class="container">
<div class="row">
<div class="col-md-12">
<h1>{post['title']}</h1>
<p class="text-muted">{post['date'].strftime('%B %-d, %Y')}</p>

{post['html']}

{COMMENTS}
</div>
</div>
</div>
"""
    page += FOOT
    outdir = os.path.join(BLOG_DIR, post['slug'])
    os.makedirs(outdir, exist_ok=True)
    with open(os.path.join(outdir, 'index.html'), 'w') as f:
        f.write(page)


def build_index(posts):
    items = ''
    for post in posts:
        items += f"""
<div style="margin-bottom: 3rem">
<h3 class="article-title" style="margin-top: 0">
<a href="/blog/{post['slug']}/">{post['title']}</a>
</h3>
<div class="article-metadata">
{post['date'].strftime('%B %-d, %Y')}
</div>
<p>{post['excerpt']}</p>
<a href="/blog/{post['slug']}/">Read more &raquo;</a>
</div>
"""
    page = HEAD.format(title='Blog', url='/blog/')
    page += f"""
<div class="container">
<div class="row">
<div class="col-md-12">
<h1>Blog</h1>
{items}
</div>
</div>
</div>
"""
    page += FOOT
    with open(os.path.join(BLOG_DIR, 'index.html'), 'w') as f:
        f.write(page)


def main():
    posts = []
    for fname in sorted(os.listdir(POSTS_DIR)):
        if fname.endswith('.md'):
            posts.append(parse_post(os.path.join(POSTS_DIR, fname)))
    posts.sort(key=lambda p: p['date'], reverse=True)

    for post in posts:
        build_post_page(post)
    build_index(posts)
    print(f'built {len(posts)} post(s) and blog/index.html')


if __name__ == '__main__':
    main()
