package com.crescentflare.unilayoutexample.reusingcontainer;

import android.content.Context;
import android.os.Bundle;
import android.support.v7.app.ActionBar;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.DefaultItemAnimator;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.util.AttributeSet;
import android.view.MenuItem;

import com.crescentflare.unilayoutexample.R;

/**
 * Reusing container example: view
 * The view containing reusable views and the adapter
 */
public class ReusingContainerView extends RecyclerView
{
    // ---
    // Initialization
    // ---

    public ReusingContainerView(Context context)
    {
        this(context, (AttributeSet)null);
    }

    public ReusingContainerView(Context context, AttributeSet attrs)
    {
        super(context, attrs);
        init(attrs);
    }

    public ReusingContainerView(Context context, AttributeSet attrs, int defStyleAttr)
    {
        this(context, attrs);
    }

    public ReusingContainerView(Context context, AttributeSet attrs, int defStyleAttr, int defStyleRes)
    {
        this(context, attrs);
    }

    private void init(AttributeSet attrs)
    {
        RecyclerView.LayoutManager layoutManager = new LinearLayoutManager(getContext());
        setLayoutManager(layoutManager);
        setItemAnimator(new DefaultItemAnimator());
    }
}
