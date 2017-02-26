package com.crescentflare.unilayout.views;

import android.content.Context;
import android.util.AttributeSet;
import android.webkit.WebView;
import android.widget.Button;

import com.crescentflare.unilayout.helpers.UniScrollListener;

/**
 * UniLayout view: a web view
 * Extends WebView to enable listening for scroll events
 */
public class UniWebView extends WebView
{
    // ---
    // Members
    // ---

    private UniScrollListener scrollListener;


    // ---
    // Initialization
    // ---

    public UniWebView(Context context)
    {
        this(context, (AttributeSet)null);
    }

    public UniWebView(Context context, AttributeSet attrs)
    {
        super(context, attrs);
        init(attrs);
    }

    public UniWebView(Context context, AttributeSet attrs, int defStyleAttr)
    {
        this(context, attrs);
    }

    public UniWebView(Context context, AttributeSet attrs, int defStyleAttr, int defStyleRes)
    {
        this(context, attrs);
    }

    private void init(AttributeSet attrs)
    {
    }


    // ---
    // Hook into scroll events
    // ---

    public void setScrollListener(UniScrollListener scrollListener)
    {
        this.scrollListener = scrollListener;
    }

    @Override
    protected void onScrollChanged(int x, int y, int oldX, int oldY)
    {
        super.onScrollChanged(x, y, oldX, oldY);
        if (scrollListener != null)
        {
            scrollListener.onScrollChanged(x, y, oldX, oldY);
        }
    }
}
