#!/usr/bin/env python3
"""
Convert legal markdown files to HTML for Firebase Hosting

Requirements: pip install markdown
"""

import markdown
import os

# HTML template
HTML_TEMPLATE = """<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{title} - BrightSide</title>
    <style>
        * {{
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }}

        body {{
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            line-height: 1.6;
            color: #212121;
            background: #fafafa;
            padding: 20px;
        }}

        .container {{
            max-width: 800px;
            margin: 0 auto;
            background: white;
            padding: 40px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }}

        h1 {{
            color: #FFB800;
            margin-bottom: 20px;
            font-size: 2.5em;
        }}

        h2 {{
            color: #212121;
            margin-top: 30px;
            margin-bottom: 15px;
            font-size: 1.8em;
            border-bottom: 2px solid #FFB800;
            padding-bottom: 5px;
        }}

        h3 {{
            color: #212121;
            margin-top: 20px;
            margin-bottom: 10px;
            font-size: 1.3em;
        }}

        p {{
            margin-bottom: 15px;
        }}

        strong {{
            color: #212121;
        }}

        ul, ol {{
            margin: 15px 0;
            padding-left: 30px;
        }}

        li {{
            margin-bottom: 8px;
        }}

        table {{
            width: 100%;
            border-collapse: collapse;
            margin: 20px 0;
            font-size: 0.9em;
        }}

        th, td {{
            border: 1px solid #e0e0e0;
            padding: 12px;
            text-align: left;
        }}

        th {{
            background: #FFB800;
            color: white;
            font-weight: 600;
        }}

        tr:nth-child(even) {{
            background: #f5f5f5;
        }}

        a {{
            color: #FFB800;
            text-decoration: none;
        }}

        a:hover {{
            text-decoration: underline;
        }}

        hr {{
            border: none;
            border-top: 1px solid #e0e0e0;
            margin: 30px 0;
        }}

        blockquote {{
            border-left: 4px solid #FFB800;
            padding-left: 20px;
            margin: 20px 0;
            font-style: italic;
            color: #757575;
        }}

        .back-link {{
            display: inline-block;
            margin-bottom: 20px;
            padding: 10px 20px;
            background: #f5f5f5;
            border-radius: 4px;
            color: #212121;
            text-decoration: none;
            transition: background 0.2s;
        }}

        .back-link:hover {{
            background: #FFB800;
            color: white;
        }}

        footer {{
            margin-top: 40px;
            padding-top: 20px;
            border-top: 1px solid #e0e0e0;
            text-align: center;
            color: #757575;
            font-size: 0.9em;
        }}
    </style>
</head>
<body>
    <div class="container">
        <a href="index.html" class="back-link">← Back to Legal</a>
        {content}
        <footer>
            <p>&copy; 2025 BrightSide. All rights reserved.</p>
            <p><a href="mailto:support@brightside.com">support@brightside.com</a></p>
        </footer>
    </div>
</body>
</html>
"""

def convert_markdown_to_html(md_path, html_path, title):
    """Convert markdown file to HTML with template"""
    # Read markdown
    with open(md_path, 'r', encoding='utf-8') as f:
        md_content = f.read()

    # Convert to HTML
    html_content = markdown.markdown(
        md_content,
        extensions=['tables', 'fenced_code', 'nl2br']
    )

    # Wrap in template
    final_html = HTML_TEMPLATE.format(
        title=title,
        content=html_content
    )

    # Write HTML
    with open(html_path, 'w', encoding='utf-8') as f:
        f.write(final_html)

if __name__ == '__main__':
    # Get directories
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_dir = os.path.dirname(script_dir)
    legal_md_dir = os.path.join(project_dir, 'docs', 'legal')
    legal_web_dir = os.path.join(project_dir, 'legal-web')

    # Create output directory if it doesn't exist
    os.makedirs(legal_web_dir, exist_ok=True)

    # Convert files
    print('Converting legal documents to HTML...\n')

    # Privacy Policy
    print('Converting privacy_policy.md → privacy.html...')
    convert_markdown_to_html(
        os.path.join(legal_md_dir, 'privacy_policy.md'),
        os.path.join(legal_web_dir, 'privacy.html'),
        'Privacy Policy'
    )
    print('✓ Generated privacy.html')

    # Terms of Service
    print('Converting terms_of_service.md → terms.html...')
    convert_markdown_to_html(
        os.path.join(legal_md_dir, 'terms_of_service.md'),
        os.path.join(legal_web_dir, 'terms.html'),
        'Terms of Service'
    )
    print('✓ Generated terms.html')

    print('\n✅ HTML generation complete!')
    print(f'\nOutput directory: {legal_web_dir}')
    print('\nNext steps:')
    print('1. Review generated HTML files')
    print('2. Deploy to Firebase Hosting: firebase deploy --only hosting:legal')
    print('3. Test URLs: https://YOUR-PROJECT.web.app/legal/privacy.html')
