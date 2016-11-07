package com.crescentflare.unilayoutexample.reusingcontainer;

import android.os.Bundle;
import android.support.v7.app.ActionBar;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.RecyclerView;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;

import com.crescentflare.unilayoutexample.R;
import com.crescentflare.unilayoutexample.reusingcontainer.views.DividerView;
import com.crescentflare.unilayoutexample.reusingcontainer.views.ItemView;
import com.crescentflare.unilayoutexample.reusingcontainer.views.SectionView;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * Reusing container example: adapter
 * Provides display of reusable items
 */
public class ReusingContainerAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder>
{
    /**
     * Members
     */

    private List<ReusableItem> items = new ArrayList<>();


    /**
     * Clear/add items
     */

    public void removeItems()
    {
        items.clear();
        notifyDataSetChanged();
    }

    public void addItem(ReusableItem item)
    {
        items.add(item);
        notifyDataSetChanged();
    }


    /**
     * Internal item access
     */

    @Override
    public int getItemCount()
    {
        return items.size();
    }

    @Override
    public int getItemViewType(int position)
    {
        ReusableItem item = items.get(position);
        if (item.getType() == null)
        {
            return -1;
        }
        return Arrays.asList(ReusableItem.Type.values()).indexOf(item.getType());
    }


    /**
     * View holder
     */

    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType)
    {
        ReusableItem.Type type = null;
        if (viewType >= 0 && viewType < ReusableItem.Type.values().length)
        {
            type = ReusableItem.Type.values()[viewType];
        }
        switch (type)
        {
            case Section:
                return new ViewHolder(new SectionView(parent.getContext()));
            case TopDivider:
                return new ViewHolder(new DividerView(parent.getContext(), false));
            case BottomDivider:
                return new ViewHolder(new DividerView(parent.getContext(), true));
            case Item:
                return new ViewHolder(new ItemView(parent.getContext()));
        }
        return new ViewHolder(new View(parent.getContext()));
    }

    @Override
    public void onBindViewHolder(RecyclerView.ViewHolder holder, int position)
    {
        ReusableItem item = items.get(position);
        switch (item.getType())
        {
            case Section:
                ((SectionView)holder.itemView).setText(item.getTitle());
                break;
            case Item:
                ((ItemView)holder.itemView).setTitle(item.getTitle());
                ((ItemView)holder.itemView).setAdditional(item.getAdditional());
                ((ItemView)holder.itemView).setValue(item.getValue());
                break;
        }
    }

    private static class ViewHolder extends RecyclerView.ViewHolder
    {
        public ViewHolder(View view)
        {
            super(view);
        }
    }
}
