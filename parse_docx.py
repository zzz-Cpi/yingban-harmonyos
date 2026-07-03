#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
使用 Windows COM 接口打开文档文件
"""

import win32com.client
from pathlib import Path
import tempfile
import os

def read_doc_with_word(file_path):
    """
    使用 Microsoft Word COM 接口读取文档
    """
    try:
        # 创建 Word 应用对象
        word = win32com.client.Dispatch("Word.Application")
        word.Visible = False

        # 打开文档
        doc = word.Documents.Open(file_path)

        # 获取文档内容
        content = doc.Content.Text

        # 关闭文档
        doc.Close(False)
        word.Quit()

        return content

    except Exception as e:
        print(f"使用 Word 打开失败: {e}")
        try:
            word.Quit()
        except:
            pass
        return None

def read_doc_with_wps(file_path):
    """
    使用 WPS Office COM 接口读取文档
    """
    try:
        # 创建 WPS 应用对象
        wps = win32com.client.Dispatch("Wps.Application")
        wps.Visible = False

        # 打开文档
        doc = wps.Documents.Open(file_path)

        # 获取文档内容
        content = doc.Content.Text

        # 关闭文档
        doc.Close(False)
        wps.Quit()

        return content

    except Exception as e:
        print(f"使用 WPS 打开失败: {e}")
        try:
            wps.Quit()
        except:
            pass
        return None

if __name__ == '__main__':
    file_path = r'c:\Users\23028\.trae-cn\attachments\6a451cabdb0b34034d1c918d\5385dd62-ebda-4c52-99a3-bb2959fbfce2_代码.docx'

    # 检查文件是否存在
    if not Path(file_path).exists():
        print(f"文件不存在: {file_path}")
        exit(1)

    print("=" * 80)
    print("尝试使用 Windows COM 接口读取文档...")
    print("=" * 80)

    # 尝试使用 Word
    print("\n尝试使用 Microsoft Word...")
    content = read_doc_with_word(file_path)

    if content:
        print("\n成功读取文档内容:")
        print("=" * 80)
        print(content)
        print("=" * 80)
    else:
        # 尝试使用 WPS
        print("\n尝试使用 WPS Office...")
        content = read_doc_with_wps(file_path)

        if content:
            print("\n成功读取文档内容:")
            print("=" * 80)
            print(content)
            print("=" * 80)
        else:
            print("\n无法通过 COM 接口读取文档。")
            print("可能的原因:")
            print("1. 系统未安装 Microsoft Word 或 WPS Office")
            print("2. 文件格式不标准或已加密")
            print("3. 文件损坏")